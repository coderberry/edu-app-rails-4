var Jsonable = require('../mixins/jsonable');

var CustomButtonSettings = Ember.Object.extend(Jsonable, {
  modifiedAt : new Date(),
  isEnabled  : false,
  isOptional : false,
  name       : null,
  launchUrl  : null,
  linkText   : null,
  iconUrl    : null,
  width      : null,
  height     : null,

  changeObserver: function() {
    this.set('modifiedAt', new Date());
  }.observes('isEnabled', 'isOptional', 'name', 'launchUrl', 'linkText', 'iconUrl', 'width', 'height'),

  getJson: function() {
    return {
      isEnabled  : this.get('isEnabled'),
      isOptional : this.get('isOptional'),
      name       : this.get('name'),
      launchUrl  : this.get('launchUrl'),
      linkText   : this.get('linkText'),
      iconUrl    : this.get('iconUrl'),
      width      : this.get('width'),
      height     : this.get('height')
    }
  }
});

module.exports = CustomButtonSettings;
