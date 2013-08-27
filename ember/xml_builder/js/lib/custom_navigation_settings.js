var Jsonable = require('../mixins/jsonable');

var CourseNavigationSettings = Ember.Object.extend(Jsonable, {
  isEnabled        : false,
  isOptional       : false,
  name             : null,
  launchUrl        : null,
  linkText         : null,
  visibility       : 'public',
  enabledByDefault : true,

  modifiedAt: function() {
    return new Date();
  }.property('isEnabled', 'isOptional', 'name', 'launchUrl', 'linkText', 'visibility', 'enabledByDefault')
});

module.exports = CourseNavigationSettings;
