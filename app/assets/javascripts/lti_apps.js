$(function() {
  $('a[data-action="deleteReview"]').click(function(e) {
    e.preventDefault();
    if (confirm('Are you sure?')) {
      var ltiAppId = $(this).data('lti-app-id');
      var reviewId = $(this).data('review-id');

      $.ajax({
        url: "/api/v1/lti_apps/" + ltiAppId + "/reviews/" + reviewId,
        dataType: 'json',
        type: 'DELETE',
      }).done(function(data) {
        $('#review-' + reviewId).remove();
      }).fail(function(err) {
        console.log(err);
      });
    }
  })
});