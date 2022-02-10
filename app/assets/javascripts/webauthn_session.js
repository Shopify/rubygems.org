$(() => {
  const FORM_SELECTOR = ".js-webauthn-session--form"
  const SUBMIT_SELECTOR = ".js-webauthn-session--submit"
  const ERROR_SELECTOR = ".js-webauthn-session--error"
  const $FORM = $(FORM_SELECTOR)
  const $SUBMIT = $(SUBMIT_SELECTOR)
  const $ERROR = $(ERROR_SELECTOR)
  const CSRF_TOKEN = $("[name='csrf-token']").attr("content")

  console.log($SUBMIT[0])

  $FORM.submit(async (e) => {
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

      const response = await fetch(`${form.action}.json`, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "X-CSRF-Token": CSRF_TOKEN,
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

      if (response.redirected) {
        window.location.href = response.url
      } else {
        const json = await response.json()
        $SUBMIT.attr("disabled", false)
        $ERROR.attr("hidden", false)
        $ERROR.text(json.message)
      }
    } catch (e) {
      $SUBMIT.attr("disabled", false)
      $ERROR.attr("hidden", false)
      $ERROR.text(e.message)
    }
  })
})
