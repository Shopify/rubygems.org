(function() {
  var handleEvent = function(event) {
    event.preventDefault()
    return event.target
  }

  var setError = function($submit, $error, message) {
    $submit.attr("disabled", false)
    $error.attr("hidden", false)
    $error.text(message)
  }

  var handleResponse = function($submit, $error, response) {
    if (response.redirected) {
      window.location.href = response.url
    } else {
      response.json().then(function (json) {
        setError($submit, $error, json.message)
      }).catch(function (error) {
        setError($submit, $error, error)
      })
    }
  }

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
      }
    }
  }

  var credentialsToBuffer = function(credentials) {
    return credentials.map(function(credential) {
      return {
        id: base64urlToBuffer(credential.id),
        type: credential.type
      }
    })
  }

  $(function() {
    var FORM_SELECTOR = ".js-new-webauthn-credential--form"
    var SUBMIT_SELECTOR = ".js-new-webauthn-credential--submit"
    var NICKNAME_INPUT_SELECTOR = ".js-new-webauthn-credential--nickname"
    var ERROR_SELECTOR = ".js-new-webauthn-credential--error"
    var $FORM = $(FORM_SELECTOR)
    var $ERROR = $(ERROR_SELECTOR)
    var $SUBMIT = $(SUBMIT_SELECTOR)
    var CSRF_TOKEN = $("[name='csrf-token']").attr("content")

    $FORM.submit(function(event) {
      var form = handleEvent(event)
      var nickname = $(NICKNAME_INPUT_SELECTOR).val()

      fetch(form.action + ".json", {
        method: "POST",
        credentials: "same-origin",
        headers: { "X-CSRF-Token": CSRF_TOKEN }
      }).then(function (response) {
        return response.json()
      }).then(function (json) {
        json.user.id = base64urlToBuffer(json.user.id)
        json.challenge = base64urlToBuffer(json.challenge)
        json.excludeCredentials = credentialsToBuffer(json.excludeCredentials)
        return navigator.credentials.create({
          publicKey: json
        })
      }).then(function (credentials) {
        return fetch(form.action + "/callback.json", {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": CSRF_TOKEN,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            credentials: credentialsToBase64(credentials),
            webauthn_credential: { nickname: nickname }
          })
        })
      }).then(function (response) {
        handleResponse($SUBMIT, $ERROR, response)
      }).catch(function (error) {
        setError($SUBMIT, $ERROR, error)
      })
    })
  })

  $(function() {
    var FORM_SELECTOR = ".js-webauthn-session--form"
    var SUBMIT_SELECTOR = ".js-webauthn-session--submit"
    var ERROR_SELECTOR = ".js-webauthn-session--error"
    var $FORM = $(FORM_SELECTOR)
    var $SUBMIT = $(SUBMIT_SELECTOR)
    var $ERROR = $(ERROR_SELECTOR)
    var CSRF_TOKEN = $("[name='csrf-token']").attr("content")

    $FORM.submit(function(e) {
      var form = handleEvent(event)
      var options = JSON.parse(form.dataset.options)
      options.challenge = base64urlToBuffer(options.challenge)
      options.userVerification = "preferred"
      options.allowCredentials = credentialsToBuffer(options.allowCredentials)
      navigator.credentials.get({
        publicKey: options
      }).then(function (credentials) {
        return fetch(form.action + ".json", {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": CSRF_TOKEN,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            credentials: credentialsToBase64(credentials)
          })
        })
      }).then(function (response) {
        handleResponse($SUBMIT, $ERROR, response)
      }).catch(function (error) {
        setError($SUBMIT, $ERROR, error)
      })
    })
  })
})()
