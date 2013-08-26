var Jsonable = require('../mixins/jsonable');

var ConfigOption = Ember.Object.extend(Jsonable, { 
  name                : '',
  default_description : '',
  type                : 'text',
  value               : '',
  is_required         : false,

  modifiedAt: function() {
    return new Date();
  }.property('name', 'description', 'type', 'value', 'required')
});

module.exports = ConfigOption;