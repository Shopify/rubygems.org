$(() => {
  const FORM_SELECTOR = ".js-new-webauthn-credential-form"
  const NICKNAME_INPUT_SELECTOR = `${FORM_SELECTOR} #webauthn_credential_nickname`
  const SUBMIT_SELECTOR = `${FORM_SELECTOR} input[type=submit]`
  const SESSION_FORM_SELECTOR = ".js-webauthn-create-session-form"
  const SESSION_SUBMIT_SELECTOR = `${SESSION_FORM_SELECTOR} input[type=submit]`
  const csrfToken = document.querySelector("[name='csrf-token']").content

  // base64urlToBuffer and bufferToBase64url are from @github/webauthn-json
  //
  // Copyright (c) 2019 GitHub, Inc.
  //
  // Permission is hereby granted, free of charge, to any person
  // obtaining a copy of this software and associated documentation
  // files (the "Software"), to deal in the Software without
  // restriction, including without limitation the rights to use,
  // copy, modify, merge, publish, distribute, sublicense, and/or sell
  // copies of the Software, and to permit persons to whom the
  // Software is furnished to do so, subject to the following
  // conditions:
  //
  // The above copyright notice and this permission notice shall be
  // included in all copies or substantial portions of the Software.
  //
  // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  // EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  // OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  // NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  // HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  // WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  // FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  // OTHER DEALINGS IN THE SOFTWARE.
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
