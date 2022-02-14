((() => {
  var handleEvent = (event) => {
    event.preventDefault()
    return event.target
  }

  var setError = ($submit, $error, message) => {
    $submit.attr("disabled", false)
    $error.attr("hidden", false)
    $error.text(message)
  }

  var handleResponse = async ($submit, $error, response) => {
    if (response.redirected) {
      window.location.href = response.url
    } else {
      var json = await response.json()
      setError($SUBMIT, $ERROR, json.message)
    }
  }

  var credentialsToBase64 = (credentials) => (
    {
      type: credentials.type,
      id: credentials.id,
      rawId: bufferToBase64url(credentials.rawId),
      clientExtensionResults: credentials.clientExtensionResults,
      response: {
        authenticatorData: bufferToBase64url(
          credentials.response.authenticatorData
        ),
        attestationObject: bufferToBase64url(
          credentials.response.attestationObject
        ),
        clientDataJSON: bufferToBase64url(
          credentials.response.clientDataJSON
        ),
        signature: bufferToBase64url(credentials.response.signature),
      },
    }
  )

  var credentialsToBuffer = (credentials) => (
    credentials.map(
      (credential) => (
        {
          id: base64urlToBuffer(credential.id),
          type: credential.type,
        }
      )
    )
  )

  $(() => {
    var FORM_SELECTOR = ".js-new-webauthn-credential--form"
    var SUBMIT_SELECTOR = `${FORM_SELECTOR} input[type=submit]`
    var NICKNAME_INPUT_SELECTOR = `${FORM_SELECTOR} #webauthn_credential_nickname`
    var ERROR_SELECTOR = ".js-new-webauthn-credential--error"
    var $FORM = $(FORM_SELECTOR)
    var $ERROR = $(ERROR_SELECTOR)
    var $SUBMIT = $(SUBMIT_SELECTOR)
    var CSRF_TOKEN = $("[name='csrf-token']").attr("content")

    $FORM.submit(async (event) => {
      try {
        var form = handleEvent(event)
        var nickname = $(NICKNAME_INPUT_SELECTOR).val()

        var createResponse = await fetch(`${form.action}.json`, {
          method: "POST",
          credentials: "same-origin",
          headers: { "X-CSRF-Token": CSRF_TOKEN },
        })

        var createJson = await createResponse.json()
        createJson.user.id = base64urlToBuffer(createJson.user.id)
        createJson.challenge = base64urlToBuffer(createJson.challenge)
        createJson.excludeCredentials = credentialsToBuffer(
          createJson.excludeCredentials
      )

        var credentials = await navigator.credentials.create({
          publicKey: createJson,
        })

        var callbackResponse = await fetch(`${form.action}/callback.json`, {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": CSRF_TOKEN,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            credentials: credentialsToBase64(credentials),
            webauthn_credential: { nickname: nickname },
          }),
        })

        handleResponse($SUBMIT, $ERROR, callbackResponse)
      } catch (e) {
        setError($SUBMIT, $ERROR, e.message)
      }
    })
  })

  $(() => {
    var FORM_SELECTOR = ".js-webauthn-session--form"
    var SUBMIT_SELECTOR = ".js-webauthn-session--submit"
    var ERROR_SELECTOR = ".js-webauthn-session--error"
    var $FORM = $(FORM_SELECTOR)
    var $SUBMIT = $(SUBMIT_SELECTOR)
    var $ERROR = $(ERROR_SELECTOR)
    var CSRF_TOKEN = $("[name='csrf-token']").attr("content")

    $FORM.submit(async (e) => {
      try {
        var form = handleEvent(event)
        var options = JSON.parse(form.dataset.options)
        options.challenge = base64urlToBuffer(options.challenge)
        // From: https://developers.yubico.com/WebAuthn/WebAuthn_Developer_Guide/User_Presence_vs_User_Verification.html
        // PREFERRED: This value indicates that the RP prefers user verification
        // for the operation if possible, but will not fail the operation if
        // the response does not have the ``AuthenticatorDataFlags.UV`` flag set.
        options.userVerification = "preferred"
        options.allowCredentials = credentialsToBuffer(
          options.allowCredentials
        )

        var credentials = await navigator.credentials.get({
          publicKey: options,
        })

        var response = await fetch(`${form.action}.json`, {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": CSRF_TOKEN,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            credentials: credentialsToBase64(credentials)
          }),
        })

        handleResponse($SUBMIT, $ERROR, response)
      } catch (e) {
        setError($SUBMIT, $ERROR, e.message)
      }
    })
  })
})())
