var Jsonable = require('../mixins/jsonable');

var CustomButtonSettings = Ember.Object.extend(Jsonable, {
  is_enabled: false,
  is_optional: false,
  name: null,
  lti_launch_url: null,
  link_text: null,
  icon_image_url: null,
  selection_width: null,
  selection_height: null,

  modifiedAt: function() {
    return new Date();
  }.property('is_enabled', 'is_optional', 'lti_launch_url', 'link_text', 'icon_image_url', 'selection_width', 'selection_height')
});

module.exports = CustomButtonSettings;
