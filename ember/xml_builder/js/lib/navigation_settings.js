var NavigationSettings = Ember.Object.extend({
  is_optional: false,
  lti_launch_url: null,
  link_text: null,

  modifiedAt: function() {
    return new Date();
  }.property('is_optional', 'lti_launch_url', 'link_text')
});

module.exports = NavigationSettings;
