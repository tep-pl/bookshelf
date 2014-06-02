  $.fn.toggler = function(parent, child_number) {
    if($(parent).next().attr('id') == 'name_active') {
      $('#name_active').slideToggle('fast');
      $('#name_active').attr('id','');
    } else {
      if($('#name_active').length) {
        $('#name_active').slideToggle('fast');
        $('#name_active').attr('id','');
      }
      $(parent).next().attr('id','name_active');
      $(parent).next().slideToggle('fast');
      $(parent).next().children().eq(child_number).focus();
    }
  }

  $('.register').click(function() {
      $.fn.toggler(this,1);
  });

  $('.nick').click(function() {
      $.fn.toggler(this,2);
  });

  $('.listed').hover(
      function() {
          $(this).children().eq(3).slideToggle('fast');
      },
      function() {
          $(this).children().eq(3).slideToggle('fast');
      }
  );

  $('#sign-up-modal').on('shown.bs.modal', function () {
      $('#bookshelf_name').focus();
  });

  $('#book-modal').on('shown.bs.modal', function () {
      $('#book_author').focus();
  });