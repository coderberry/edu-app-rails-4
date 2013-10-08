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

  // Manage the adding and removing of custom options
  $('form').on('click', '.remove_fields', function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('tr').hide();
    event.preventDefault();
  });
  $('form').on('click', '.add_fields', function(event) {
    var time = new Date().getTime();
    var regexp = new RegExp($(this).data('id'), 'g');
    var foo = $(this);
    $('tbody.fields').append($(this).data('fields').replace(regexp, time));
    event.preventDefault();
  });
});