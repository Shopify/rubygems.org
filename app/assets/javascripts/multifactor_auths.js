$(() => {
  var popUp = (e) => {
    e.preventDefault()
    e.returnValue = ""
  }

  var $RECOVERY_CODES = $("#recovery-codes--list")
  var COPY_ICON_SELECTOR = "#recovery-codes--copy-icon"
  var $COPY_ICON = $(COPY_ICON_SELECTOR)
  var $CHECKBOX_INPUT = $("#recovery-codes--checkbox")
  var CHECKBOX_INPUT = $CHECKBOX_INPUT[0]
  var FORM_SUBMIT = $("#recovery-codes--submit")[0]

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
})
