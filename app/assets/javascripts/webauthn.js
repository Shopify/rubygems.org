((() => {
  const handleEvent = (event) => {
    event.preventDefault()
    return event.target
  }

  const setError = ($submit, $error, message) => {
    $submit.attr("disabled", false)
    $error.attr("hidden", false)
    $error.text(message)
  }

  const handleResponse = async ($submit, $error, response) => {
    if (response.redirected) {
      window.location.href = response.url
    } else {
      const json = await response.json()
      setError($SUBMIT, $ERROR, json.message)
    }
  }

  const credentialsToBase64 = (credentials) => (
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

  const credentialsToBuffer = (credentials) => (
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
    const FORM_SELECTOR = ".js-new-webauthn-credential--form"
    const SUBMIT_SELECTOR = `${FORM_SELECTOR} input[type=submit]`
    const NICKNAME_INPUT_SELECTOR = `${FORM_SELECTOR} #webauthn_credential_nickname`
    const ERROR_SELECTOR = ".js-new-webauthn-credential--error"
    const $FORM = $(FORM_SELECTOR)
    const $ERROR = $(ERROR_SELECTOR)
    const $SUBMIT = $(SUBMIT_SELECTOR)
    const CSRF_TOKEN = $("[name='csrf-token']").attr("content")

    $FORM.submit(async (event) => {
      try {
        const form = handleEvent(event)
        const nickname = $(NICKNAME_INPUT_SELECTOR).val()

        const createResponse = await fetch(`${form.action}.json`, {
          method: "POST",
          credentials: "same-origin",
          headers: { "X-CSRF-Token": CSRF_TOKEN },
        })

        const createJson = await createResponse.json()
        createJson.user.id = base64urlToBuffer(createJson.user.id)
        createJson.challenge = base64urlToBuffer(createJson.challenge)
        createJson.excludeCredentials = credentialsToBuffer(
          createJson.excludeCredentials
      )

        const credentials = await navigator.credentials.create({
          publicKey: createJson,
        })

        const callbackResponse = await fetch(`${form.action}/callback.json`, {
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
    const FORM_SELECTOR = ".js-webauthn-session--form"
    const SUBMIT_SELECTOR = ".js-webauthn-session--submit"
    const ERROR_SELECTOR = ".js-webauthn-session--error"
    const $FORM = $(FORM_SELECTOR)
    const $SUBMIT = $(SUBMIT_SELECTOR)
    const $ERROR = $(ERROR_SELECTOR)
    const CSRF_TOKEN = $("[name='csrf-token']").attr("content")

    $FORM.submit(async (e) => {
      try {
        const form = handleEvent(event)
        const options = JSON.parse(form.dataset.options)
        options.challenge = base64urlToBuffer(options.challenge)
        // From: https://developers.yubico.com/WebAuthn/WebAuthn_Developer_Guide/User_Presence_vs_User_Verification.html
        // PREFERRED: This value indicates that the RP prefers user verification
        // for the operation if possible, but will not fail the operation if
        // the response does not have the ``AuthenticatorDataFlags.UV`` flag set.
        options.userVerification = "preferred"
        options.allowCredentials = credentialsToBuffer(
          options.allowCredentials
        )

        const credentials = await navigator.credentials.get({
          publicKey: options,
        })

        const response = await fetch(`${form.action}.json`, {
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
