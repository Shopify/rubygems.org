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