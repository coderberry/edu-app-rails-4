var LtiAppsController = Ember.ArrayController.extend({
  listStyle: "thumbnails",
  lti_apps: [],
  sortProperties: ['name'],
  filter: "",

  content: function() {
    var filter = this.get('filter');

    if (Ember.isEmpty(filter)) {
      return this.get('lti_apps');
    } else {
      return this.get('lti_apps').filter(function(item, index, enumerable){
        return item.get('name').toLowerCase().match(filter.toLowerCase());
      });
    }
    
  }.property('filter', 'lti_apps.@each'),

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

