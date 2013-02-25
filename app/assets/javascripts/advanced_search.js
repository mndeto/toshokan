(function ($) {

  $(function () {
    
    $('.advanced-search').each(function () {
      // Disable simple search
      $('#searchbar').find('input, button, select').attr('disabled', 'disabled');

      // Disable advanced search link
      $('#more_options_toggle').addClass('disabled').click(function () {
        // Make sure that link doesn't get focus after clicking on it
        this.blur();
        return false;
      });
    });

  });
})(jQuery);
