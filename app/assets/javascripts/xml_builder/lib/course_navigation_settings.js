App.CourseNavigationSettings = Ember.Object.extend({
  lti_launch_url: null,
  link_text: null,
  visibility: 'public',
  enabledByDefault: true,

  modifiedAt: function() {
    return new Date();
  }.property('lti_launch_url', 'link_text', 'visibility', 'enabledByDefault')
});