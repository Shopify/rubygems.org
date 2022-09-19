$(function () {
  var popUp = function (e) {
    e.preventDefault();
    e.returnValue = "";
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

  var recoveryCodes = $("#recovery-codes--list")
  var copyIconSelector = "#recovery-codes--copy-icon"
  var copyIcon = $(copyIconSelector)
  var checkboxInputField = $("#recovery-codes--checkbox")
  var checkboxInput = checkboxInputField[0]
  var formSubmit = $("#recovery-codes--submit")[0]

  if (recoveryCodes.length > 0) {
    window.addEventListener("beforeunload", popUp)
    $(".form__submit").on("click", confirmNoRecoveryCopy);

    new ClipboardJS(copyIconSelector)

    copyIcon.click(function (e) {
      copyIcon.text(copyIcon.data("copied"))

      if (!copyIcon.is(".clicked")) {
        e.preventDefault()
        copyIcon.addClass("clicked")
        window.removeEventListener("beforeunload", popUp)
        $(".form__submit").unbind("click", confirmNoRecoveryCopy);
      }
    })

    checkboxInputField.change(function () {
      if (checkboxInput.checked) {
        formSubmit.disabled = false
      } else {
        formSubmit.disabled = true
      }
    })
  }
})
