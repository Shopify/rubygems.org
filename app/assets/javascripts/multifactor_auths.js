(function() {
  const popUp = (e) => {
    e.preventDefault()
    e.returnValue = ""
  }

  const $RECOVERY_CODES = $("#recovery-codes--list")
  const COPY_ICON_SELECTOR = "#recovery-codes--copy-icon"
  const $COPY_ICON = $(COPY_ICON_SELECTOR)
  const $CHECKBOX_INPUT = $("#recovery-codes--checkbox")
  const CHECKBOX_INPUT = $CHECKBOX_INPUT[0]
  const FORM_SUBMIT = $("#recovery-codes--submit")[0]

  if ($RECOVERY_CODES.length > 0) {
    window.addEventListener("beforeunload", popUp)

    new ClipboardJS(COPY_ICON_SELECTOR)

    $COPY_ICON.click((e) => {
      $COPY_ICON.text($COPY_ICON.data("copied"))

      if (!$COPY_ICON.is(".clicked")) {
        e.preventDefault()
        $COPY_ICON.addClass("clicked")
        window.removeEventListener("beforeunload", popUp)
      }
    })

    $CHECKBOX_INPUT.change(() => {
      if (CHECKBOX_INPUT.checked) {
        FORM_SUBMIT.disabled = false
      } else {
        FORM_SUBMIT.disabled = true
      }
    })
  }
}())
