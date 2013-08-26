var Jsonable = require('../mixins/jsonable');

var NavigationSettings = Ember.Object.extend(Jsonable, {
  is_enabled: false,
  is_optional: false,
  name: null,
  lti_launch_url: null,
  link_text: null,

  modifiedAt: function() {
    return new Date();
  }.property('is_enabled', 'is_optional', 'lti_launch_url', 'link_text')
});

module.exports = NavigationSettings;
