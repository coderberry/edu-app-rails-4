var Jsonable = require('../mixins/jsonable');

var ConfigOption = Ember.Object.extend(Jsonable, { 
  name         : '',
  description  : '',
  type         : 'text',
  defaultValue : '',
  isRequired   : false,

  modifiedAt: function() {
    return new Date();
  }.property('name', 'description', 'type', 'defaultValue', 'isRequired')
});

module.exports = ConfigOption;