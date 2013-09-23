$(function() {
  $('*[data-toggle="popover"]').popover({ container: 'body', trigger: 'focus' });
  $('input[name="cartridge_source"]').change(function() {
    $('*[data-toggle="cartridge_source"]').hide();
    $('*[data-target="' + $(this).val() + '"]').show();
  });
  $('#supported_platforms_all').click(function() {
    if ($(this).is(':checked')) {
      $('input[data-collection="checkbox-platforms"]').attr('disabled', 'disabled');
    }
  });
  $('#supported_platforms_some').click(function() {
    if ($(this).is(':checked')) {
      $('input[data-collection="checkbox-platforms"]').removeAttr('disabled');
    }
  });
});