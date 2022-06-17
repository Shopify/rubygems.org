$(function () {
  var popUp = function (e) {
    e.preventDefault()
    e.returnValue = ""
  }

function confirmNoRecoveryCopy (e, from) {
  if (from == null){
    e.preventDefault();
    if (confirm("Leave without copying recovery codes?")) {
      window.removeEventListener("beforeunload", popUp);
      $(this).trigger('click', ["non-null"]);
    }
  }
}

  var $RECOVERY_CODES = $("#recovery-codes--list")
  var COPY_ICON_SELECTOR = "#recovery-codes--copy-icon"
  var $COPY_ICON = $(COPY_ICON_SELECTOR)
  var $CHECKBOX_INPUT = $("#recovery-codes--checkbox")
  var CHECKBOX_INPUT = $CHECKBOX_INPUT[0]
  var FORM_SUBMIT = $("#recovery-codes--submit")[0]

  if ($RECOVERY_CODES.length > 0) {
    window.addEventListener("beforeunload", popUp)
    $(".form__submit").on("click", confirmNoRecoveryCopy);

    new ClipboardJS(COPY_ICON_SELECTOR)

    $COPY_ICON.click(function (e) {
      $COPY_ICON.text($COPY_ICON.data("copied"))

      if (!$COPY_ICON.is(".clicked")) {
        e.preventDefault()
        $COPY_ICON.addClass("clicked")
        window.removeEventListener("beforeunload", popUp)
        $(".form__submit").unbind("click", confirmNoRecoveryCopy);
      }
    })

    $CHECKBOX_INPUT.change(function () {
      if (CHECKBOX_INPUT.checked) {
        FORM_SUBMIT.disabled = false
      } else {
        FORM_SUBMIT.disabled = true
      }
    })
  }
})
