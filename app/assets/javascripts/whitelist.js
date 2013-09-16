$(function() {
  $('a[data-toggle="lao-visible"]').click(function() {
    var organizationId = $(this).data('organization-id');
    var laoId = $(this).data('lao-id');
    var visibleBtn = $('#btn-lao-toggle-visible-' + laoId);
    var hiddenBtn = $('#btn-lao-toggle-hidden-' + laoId);
    $.post('/organizations/' + organizationId + '/toggle_whitelist_item/' + laoId, function(data) {
      var isVisible = data.is_visible;
      if (isVisible === true) {
        hiddenBtn.hide();
        visibleBtn.show();
      } else {
        visibleBtn.hide();
        hiddenBtn.show();
      }
    });
  })
});