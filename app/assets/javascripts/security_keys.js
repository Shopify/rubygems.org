// base64urlToBuffer and bufferToBase64url are from @github/webauthn-json
// see: https://github.com/github/webauthn-json/blob/main/LICENSE.md
$(() => {
  const FORM_SELECTOR = ".js-new-security-key-form"
  const NICKNAME_INPUT_SELECTOR = `${FORM_SELECTOR} #security_key_nickname`
  const SUBMIT_SELECTOR = `${FORM_SELECTOR} input[type=submit]`
  const csrfToken = document.querySelector("[name='csrf-token']").content

  const base64urlToBuffer = (baseurl64String) => {
    const padding = "==".slice(0, (4 - (baseurl64String.length % 4)) % 4)
    const base64String =
      baseurl64String.replace(/-/g, "+").replace(/_/g, "/") + padding
    const str = atob(base64String)
    const buffer = new ArrayBuffer(str.length)
    const byteView = new Uint8Array(buffer)
    for (let i = 0; i < str.length; i++) {
      byteView[i] = str.charCodeAt(i)
    }
    return buffer
  }

  const bufferToBase64url = (buffer) => {
    const byteView = new Uint8Array(buffer)
    let str = ""
    for (const charCode of byteView) {
      str += String.fromCharCode(charCode)
    }
    const base64String = btoa(str)
    const base64urlString = base64String
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=/g, "")
    return base64urlString
  }

  $(FORM_SELECTOR).submit(async (event) => {
    try {
      event.preventDefault()

      const form = event.target
      const nickname = document.querySelector(NICKNAME_INPUT_SELECTOR).value

      let createResponse = await fetch(form.action, {
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

      const callbackResponse = await fetch(`${form.action}/callback`, {
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
          security_key: { nickname: nickname },
        }),
      })

      if (callbackResponse.status == 200) {
        window.location = form.action
      } else {
        const callbackResponseJSON = await callbackResponse.json()
        alert(callbackResponseJSON.message)
      }
    } catch (e) {
      document.querySelector(SUBMIT_SELECTOR).disabled = false
      throw(e)
    }
  })
})
