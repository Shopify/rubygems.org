$(function() {
  if ($('#user_gem_query').focus){
    console.log("I'm here!");
    autocomplete2($('#user_gem_query'));
    var suggest = $('#suggest-home');
  }

  var indexNumber = -1;

  function autocomplete2(search) {
    search.bind('input', function(e) {
      var term = $.trim($(search).val());
      if (term.length >= 0) {
        $.ajax({
          url: '/profile/gem_autocomplete',
          type: 'GET',
          data: ('query=' + term),
          processData: false,
          dataType: 'json'
        }).done(function(data) {
          addToSuggestList(search, data);
        });
      } else {
        suggest.find('li').remove();
      }
    });

    search.keydown(function(e) {
      if (e.keyCode == 38) {
        indexNumber--;
        focusItem(search);
      } else if (e.keyCode == 40) {
        indexNumber++;
        focusItem(search);
      };
    });
  };

  function addToSuggestList(search, data) {
    suggest.find('li').remove();

    for (var i = 0; i < data.length && i < 10; i++) {
      var newItem = $('<li>').text(data[i]);
      $(newItem).attr('class', 'menu-item');
      suggest.append(newItem);

      /* submit the search form if li item was clicked */
      newItem.click(function() {
        search.val($(this).html());
      });

      newItem.hover(function () {
        $('li').removeClass('selected');
        $(this).addClass("selected");
      });
    }

    indexNumber = -1;
  };

  function focusItem(search){
    var suggestLength = suggest.find('li').length;
    if (indexNumber >= suggestLength) indexNumber = 0;
    if (indexNumber < 0) indexNumber = suggestLength - 1;

    $('li').removeClass('selected');
    suggest.find('li').eq(indexNumber).addClass('selected');
    search.val(suggest.find('.selected').text());
  };

  /* remove suggest drop down if clicked anywhere on page */
  $('html').click(function(e) { suggest.find('li').remove(); });
});
