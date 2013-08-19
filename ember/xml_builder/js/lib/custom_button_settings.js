var CustomButtonSettings = Ember.Object.extend({
  lti_launch_url: null,
  link_text: null,
  icon_image_url: null,
  selection_width: null,
  selection_height: null,

  modifiedAt: function() {
    return new Date();
  }.property('lti_launch_url', 'link_text', 'icon_image_url', 'selection_width', 'selection_height')
});

module.exports = CustomButtonSettings;
