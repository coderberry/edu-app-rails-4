$(function() {
  $('*[data-toggle="popover"]').popover({ container: 'body', trigger: 'focus' });
  $('input[name="cartridge_source"]').change(function() {
    $('*[data-toggle="cartridge_source"]').hide();
    $('*[data-target="' + $(this).val() + '"]').show();
  });
});