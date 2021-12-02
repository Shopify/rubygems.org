$(() => {
  const FORM_SELECTOR = ".js-new-webauthn-credential-form"
  const NICKNAME_INPUT_SELECTOR = `${FORM_SELECTOR} #webauthn_credential_nickname`
  const SUBMIT_SELECTOR = `${FORM_SELECTOR} input[type=submit]`
  const SESSION_FORM_SELECTOR = ".js-webauthn-create-session-form"
  const SESSION_SUBMIT_SELECTOR = `${SESSION_FORM_SELECTOR} input[type=submit]`
  const csrfToken = document.querySelector("[name='csrf-token']").content

  $(FORM_SELECTOR).submit(async (event) => {
    try {
      event.preventDefault()

      const form = event.target
      const nickname = document.querySelector(NICKNAME_INPUT_SELECTOR).value

      let createResponse = await fetch(`${form.action}.json`, {
        method: "POST",
        credentials: "same-origin",
        headers: { "X-CSRF-Token": csrfToken },
      })

      createResponse = await createResponse.json()
      createResponse.user.id = base64urlToBuffer(createResponse.user.id)
      createResponse.challenge = base64urlToBuffer(createResponse.challenge)
      createResponse.excludeCredentials = createResponse.excludeCredentials.map(
        (excludeCredential) => {
          return {
            id: base64urlToBuffer(excludeCredential.id),
            type: excludeCredential.type,
          }
        }
      )

      const credentials = await navigator.credentials.create({
        publicKey: createResponse,
      })

      let callbackResponse = await fetch(`${form.action}/callback.json`, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          credentials: {
            type: credentials.type,
            id: credentials.id,
            rawId: bufferToBase64url(credentials.rawId),
            clientExtensionResults: credentials.clientExtensionResults,
            response: {
              attestationObject: bufferToBase64url(
                credentials.response.attestationObject
              ),
              clientDataJSON: bufferToBase64url(
                credentials.response.clientDataJSON
              ),
            },
          },
          webauthn_credential: { nickname: nickname },
        }),
      })

      if (callbackResponse.status == 200) {
        callbackResponse = await callbackResponse.json()
        window.location.href = callbackResponse.location
      } else {
        callbackResponse = await callbackResponse.json()
        alert(callbackResponse.message)
      }
    } catch (e) {
      document.querySelector(SUBMIT_SELECTOR).disabled = false
      throw e
    }
  })

  $(SESSION_FORM_SELECTOR).submit(async (e) => {
    try {
      event.preventDefault()

      const form = event.target
      const options = JSON.parse(form.dataset.options)
      options.challenge = base64urlToBuffer(options.challenge)
      // From: https://developers.yubico.com/WebAuthn/WebAuthn_Developer_Guide/User_Presence_vs_User_Verification.html
      // PREFERRED: This value indicates that the RP prefers user verification
      // for the operation if possible, but will not fail the operation if
      // the response does not have the ``AuthenticatorDataFlags.UV`` flag set.
      options.userVerification = "preferred"
      options.allowCredentials = options.allowCredentials.map(
        (allowCredential) => {
          return {
            id: base64urlToBuffer(allowCredential.id),
            type: allowCredential.type,
          }
        }
      )

      const credentials = await navigator.credentials.get({
        publicKey: options,
      })

      let callbackResponse = await fetch(`${form.action}.json`, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          credentials: {
            type: credentials.type,
            id: credentials.id,
            rawId: bufferToBase64url(credentials.rawId),
            clientExtensionResults: credentials.clientExtensionResults,
            response: {
              authenticatorData: bufferToBase64url(
                credentials.response.authenticatorData
              ),
              clientDataJSON: bufferToBase64url(
                credentials.response.clientDataJSON
              ),
              signature: bufferToBase64url(credentials.response.signature),
            },
          },
        }),
      })

      if (callbackResponse.status == 200) {
        callbackResponse = await callbackResponse.json()
        window.location.href = callbackResponse.location
      } else {
        callbackResponse = await callbackResponse.json()
        alert(callbackResponse.message)
      }
    } catch (e) {
      document.querySelector(SESSION_SUBMIT_SELECTOR).disabled = false
      throw e
    }
  })
})
