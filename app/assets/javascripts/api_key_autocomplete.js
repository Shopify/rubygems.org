$(function() {
  autocomplete2($('#user_gem_query'));
  var suggest = $('#suggest-home');
  var indexNumber = -1;

  function autocomplete2(search) {
    search.on('input focus', function(_e) {
      var term = $.trim($(search).val());
      $.ajax({
        url: '/profile/gem_autocomplete',
        type: 'GET',
        data: ('query=' + term),
        processData: false,
        dataType: 'json'
      }).done(function(data) {
        addToSuggestList(search, data);
      });
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

    setInitialGemScope(search);
  };

  function setInitialGemScope(search){
    var id = $('#api_key_rubygem_id').val();
    if (id == "-1"){
      return;
    }
    var name =  $('#api_key_rubygem_id').attr('class');
    if ( name == "" ){
      name = "All gems";
    }
    console.log(name);
    console.log(id);
    selectGem(name, id, search);
  }

  function addToSuggestList(search, data) {
    suggest.find('option').remove();

    for (var i = 0; i < data.length && i < 10; i++) {
      var newItem = $('<option>').text(data[i].name);
      $(newItem).attr('class', 'menu-item');
      $(newItem).attr('value', data[i].id);
      suggest.append(newItem);

      newItem.click(function() {
        selectGem($(this).html(), $(this).val(), search);
        suggest.find('option').remove();
      });

      newItem.hover(function () {
        $('option').removeClass('selected');
        $(this).addClass("selected");
      });
    }

    indexNumber = -1;
  };

  function selectGem(name, id, search){
    var selectedGem = $('<li>').text(name);
    $('#api_key_rubygem_id').attr('value', id);
    $('#selected-gem').append(selectedGem);
    var deleteBtn = $('<input type="button" style="margin: 10px" value="trash me"/>');
    selectedGem.append(deleteBtn);
    search.prop('type', 'hidden');

    deleteBtn.click(function() {
      selectedGem.remove();
      $('#api_key_rubygem_id').attr('value', -1);
      search.prop('type', 'search');
    })
  }

  function focusItem(search){
    var suggestLength = suggest.find('option').length;
    if (indexNumber >= suggestLength) indexNumber = 0;
    if (indexNumber < 0) indexNumber = suggestLength - 1;

    $('option').removeClass('selected');
    suggest.find('option').eq(indexNumber).addClass('selected');
    search.val(suggest.find('.selected').text());
  };

  // /* remove suggest drop down if clicked anywhere on page *
  // $('html').click(function(e) { 
  //   if (!$('#g').contains(e.target)) {
  //     suggest.find('option').remove();
  //     //Do something click is outside specified element
  //   }
  //  });
});
