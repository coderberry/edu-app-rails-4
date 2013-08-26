var Jsonable = require('../mixins/jsonable');

var CourseNavigationSettings = Ember.Object.extend(Jsonable, {
  is_enabled: false,
  is_optional: false,
  name: null,
  lti_launch_url: null,
  link_text: null,
  visibility: 'public',
  enabledByDefault: true,

  modifiedAt: function() {
    return new Date();
  }.property('is_enabled', 'is_optional', 'lti_launch_url', 'link_text', 'visibility', 'enabledByDefault')
});

module.exports = CourseNavigationSettings;
