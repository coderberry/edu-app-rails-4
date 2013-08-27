var Jsonable = require('../mixins/jsonable');

var CustomField = Ember.Object.extend(Jsonable, { 
  name  : '',
  value : '',

  modifiedAt: function() {
    return new Date();
  }.property('name', 'value')
});

module.exports = CustomField;