var LtiAppsController = Ember.ArrayController.extend({
  listStyle: "thumbnails",

  showDetails: function() {
    if (this.get('listStyle') === 'details') {
      $('a[data-display="list"]').removeClass('selected');
      $('a[data-display="details"]').addClass('selected');
      $('div.thumbnail-view').hide();
      $('div.details-view').show();
      $('li.lti-app').removeClass('col-sm-6')
                     .removeClass('col-lg-4')
                     .removeClass('as-list')
                     .addClass('col-sm-12')
                     .addClass('col-lg-12')
                     .addClass('as-details');
    }
  }.observes('listStyle'),

  showThumbnails: function() {
    if (this.get('listStyle') === 'thumbnails') {
      $('a[data-display="details"]').removeClass('selected');
      $('a[data-display="list"]').addClass('selected');
      $('div.details-view').hide();
      $('div.thumbnail-view').show();
      $('li.lti-app').removeClass('col-sm-12')
                     .removeClass('col-lg-12')
                     .removeClass('as-details')
                     .addClass('col-sm-6')
                     .addClass('col-lg-4')
                     .addClass('as-list');
    }
  }.observes('listStyle'),

  displayAsDetails: function() {
    this.set('listStyle', 'details');
  },

  displayAsList: function() {
    this.set('listStyle', 'thumbnails');
  },
});

module.exports = LtiAppsController;

