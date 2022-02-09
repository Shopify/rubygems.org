//= require jquery3
//= require jquery_ujs
//= require clipboard
//= require github_buttons
//= require webauthn-json
//= require_tree .

function handleClick(event, nav, removeNavExpandedClass, addNavExpandedClass) {
  var isMobileNavExpanded = nav.popUp.hasClass(nav.expandedClass);

  event.preventDefault();

  if (isMobileNavExpanded) {
    removeNavExpandedClass();
  } else {
    addNavExpandedClass();
  }
}
