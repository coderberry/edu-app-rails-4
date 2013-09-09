var Jsonable = require('../mixins/jsonable');

var CustomButtonSettings = Ember.Object.extend(Jsonable, {
  modified_at : new Date(),
  is_enabled  : false,
  is_optional : false,
  name        : null,
  launch_url  : null,
  link_text   : null,
  icon_url    : null,
  width       : null,
  height      : null,

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes('is_enabled', 'is_optional', 'name', 'launch_url', 'link_text', 'icon_url', 'width', 'height'),

  getJson: function() {
    return {
      is_enabled  : this.get('is_enabled'),
      is_optional : this.get('is_optional'),
      name        : this.get('name'),
      launch_url  : this.get('launch_url'),
      link_text   : this.get('link_text'),
      icon_url    : this.get('icon_url'),
      width       : this.get('width'),
      height      : this.get('height')
    }
  }
});

module.exports = CustomButtonSettings;
