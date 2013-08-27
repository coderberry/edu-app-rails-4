var Jsonable = require('../mixins/jsonable');

var CustomButtonSettings = Ember.Object.extend(Jsonable, {
  isEnabled  : false,
  isOptional : false,
  name       : null,
  launchUrl  : null,
  linkText   : null,
  iconUrl    : null,
  width      : null,
  height     : null,

  modifiedAt: function() {
    return new Date();
  }.property('isEnabled', 'isOptional', 'name', 'launchUrl', 'linkText', 'iconUrl', 'width', 'height')
});

module.exports = CustomButtonSettings;
