(function() {
  // var flashBannerTemplate = `<div id="flash-border" class="flash">
  //                             <div class="flash-wrap">
  //                               <div id="flash_notice" class="l-wrap--b"><span><b>${lolMessage}</b></span></div>
  //                             </div>
  //                           </div>`;

  var handleEvent = function(event) {
    event.preventDefault();
    return event.target;
  };

  var setError = function(submit, error, message) {
    submit.attr("disabled", false);
    error.attr("hidden", false);
    error.text(message);
    // add a flash banner with the message
  };

  var htmlResponseType = function(response) {
    return response.headers.get("content-type")?.includes("html");
  }

  var setHtml = function(submit, responseError, response) {
    response.text().then(function (html) {
      document.body.innerHTML = html;
    }).catch(function (error) {
      setError(submit, responseError, error);
    });
  }

  var setJsonError = function(submit, responseError, response) {
    response.json().then(function (json) {
      if (json["html"]) {
        document.body.innerHTML = json["html"];
      }
      setError(submit, responseError, json.message);
    }).catch(function (error) {
      setError(submit, responseError, error);
    });
  }

  var handleResponse = function(submit, responseError, response) {
    if (response.redirected) {
      window.location.href = response.url;
    } else {
      if (htmlResponseType(response)) {
        setHtml(submit, responseError, response);
      }
      else {
        setJsonError(submit, responseError, response);
      }
    }
  };

  var credentialsToBase64 = function(credentials) {
    return {
      type: credentials.type,
      id: credentials.id,
      rawId: bufferToBase64url(credentials.rawId),
      clientExtensionResults: credentials.clientExtensionResults,
      response: {
        authenticatorData: bufferToBase64url(credentials.response.authenticatorData),
        attestationObject: bufferToBase64url(credentials.response.attestationObject),
        clientDataJSON: bufferToBase64url(credentials.response.clientDataJSON),
        signature: bufferToBase64url(credentials.response.signature)
      },
    };
  };

  var credentialsToBuffer = function(credentials) {
    return credentials.map(function(credential) {
      return {
        id: base64urlToBuffer(credential.id),
        type: credential.type
      };
    });
  };

  $(function() {
    var credentialForm = $(".js-new-webauthn-credential--form");
    var credentialError = $(".js-new-webauthn-credential--error");
    var credentialSubmit = $(".js-new-webauthn-credential--submit");
    var csrfToken = $("[name='csrf-token']").attr("content");

    credentialForm.submit(function(event) {
      var form = handleEvent(event);
      var nickname = $(".js-new-webauthn-credential--nickname").val();

      fetch(form.action + ".json", {
        method: "POST",
        credentials: "same-origin",
        headers: { "X-CSRF-Token": csrfToken }
      }).then(function (response) {
        return response.json();
      }).then(function (json) {
        json.user.id = base64urlToBuffer(json.user.id);
        json.challenge = base64urlToBuffer(json.challenge);
        json.excludeCredentials = credentialsToBuffer(json.excludeCredentials);
        return navigator.credentials.create({
          publicKey: json
        });
      }).then(function (credentials) {
        return fetch(form.action + "/callback.json", {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": csrfToken,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            credentials: credentialsToBase64(credentials),
            webauthn_credential: { nickname: nickname }
          })
        });
      }).then(function (response) {
        handleResponse(credentialSubmit, credentialError, response);
      }).catch(function (error) {
        setError(credentialSubmit, credentialError, error);
      });
    });
  });

  $(function() {
    var sessionForm = $(".js-webauthn-session--form");
    var sessionSubmit = $(".js-webauthn-session--submit");
    var sessionError = $(".js-webauthn-session--error");
    var csrfToken = $("[name='csrf-token']").attr("content");

    sessionForm.submit(function(event) {
      var form = handleEvent(event);
      var options = JSON.parse(form.dataset.options);
      options.challenge = base64urlToBuffer(options.challenge);
      options.allowCredentials = credentialsToBuffer(options.allowCredentials);
      navigator.credentials.get({
        publicKey: options
      }).then(function (credentials) {
        return fetch(form.action + ".html", {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": csrfToken,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            credentials: credentialsToBase64(credentials)
          })
        });
      }).then(function (response) {
        handleResponse(sessionSubmit, sessionError, response);
      }).catch(function (error) {
        setError(sessionSubmit, sessionError, error);
      });
    });
  });
})();



// re-compose a flash banner in this JS file (<h1> fjhdsklafjdsa </h1>)
// On page load, find the element you want to attach the flash banner to (document/./getElementById('theHeader'))
// theHeader.innerHtml = <recoposed flash banner>

// all to be json
// have a key that would store the html? naughty?

// all to be html
// instead of setting the error with json
// set a flash banner with the error
// render the same view with the error banner
