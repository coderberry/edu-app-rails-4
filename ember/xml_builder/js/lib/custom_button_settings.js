var Jsonable = require('../mixins/jsonable');

var CustomButtonSettings = Ember.Object.extend(Jsonable, {
  modified_at : new Date(),
  enabled  : false,
  is_optional : false,
  name        : null,
  url         : null,
  text        : null,
  icon_url    : null,
  selection_width   : null,
  selection_height  : null,

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes('enabled', 'is_optional', 'name', 'url', 'text', 'icon_url', 'selection_width', 'selection_height'),

  getJson: function() {
    return {
      enabled     : this.get('enabled'),
      is_optional : this.get('is_optional'),
      url         : this.get('url'),
      text        : this.get('text'),
      icon_url    : this.get('icon_url'),
      selection_width       : this.get('selection_width'),
      selection_height      : this.get('selection_height')
    }
  }
});

module.exports = CustomButtonSettings;
