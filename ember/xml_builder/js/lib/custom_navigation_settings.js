var Jsonable = require('../mixins/jsonable');

var CourseNavigationSettings = Ember.Object.extend(Jsonable, {
  modifiedAt       : new Date(),
  isEnabled        : false,
  isOptional       : false,
  name             : null,
  launchUrl        : null,
  linkText         : null,
  visibility       : 'public',
  enabledByDefault : true,

  changeObserver: function() {
    this.set('modifiedAt', new Date());
  }.observes('isEnabled', 'isOptional', 'name', 'launchUrl', 'linkText', 'visibility', 'enabledByDefault'),

  getJson: function() {
    return {
      isEnabled        : this.get('isEnabled'),
      isOptional       : this.get('isOptional'),
      name             : this.get('name'),
      launchUrl        : this.get('launchUrl'),
      linkText         : this.get('linkText'),
      visibility       : this.get('visibility'),
      enabledByDefault : this.get('enabledByDefault')
    }
  }
});

module.exports = CourseNavigationSettings;
