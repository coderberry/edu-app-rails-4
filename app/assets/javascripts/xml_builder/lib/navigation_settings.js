App.NavigationSettings = Ember.Object.extend({
  lti_launch_url: null,
  link_text: null,

  modifiedAt: function() {
    return new Date();
  }.property('lti_launch_url', 'link_text')
});