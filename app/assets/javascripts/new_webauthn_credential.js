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
      event.preventDefault()

      const form = event.target
      const nickname = $(NICKNAME_INPUT_SELECTOR).val()

      const createResponse = await fetch(`${form.action}.json`, {
        method: "POST",
        credentials: "same-origin",
        headers: { "X-CSRF-Token": CSRF_TOKEN },
      })

      const createJson = await createResponse.json()
      createJson.user.id = base64urlToBuffer(createJson.user.id)
      createJson.challenge = base64urlToBuffer(createJson.challenge)
      createJson.excludeCredentials = createJson.excludeCredentials.map(
        (excludeCredential) => {
          return {
            id: base64urlToBuffer(excludeCredential.id),
            type: excludeCredential.type,
          }
        }
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

      const callbackJson = await callbackResponse.json()

      if (callbackResponse.status == 200) {
        if (callbackJson.recovery_html) {
          $SUBMIT.attr("disabled", false)
          $ERROR.attr("hidden", true)
          $ERROR.text("")
          $FORM.parent().html(callbackJson.recovery_html)
          window.rubygems.setupRecoveryCodes()
        } else {
          window.location.href = callbackJson.location
        }
      } else {
        $SUBMIT.attr("disabled", false)
        $ERROR.attr("hidden", false)
        $ERROR.text(callbackJson.message)
      }
    } catch (e) {
      $SUBMIT.attr("disabled", false)
      $ERROR.attr("hidden", false)
      $ERROR.text(e.message)
    }
  })
})
