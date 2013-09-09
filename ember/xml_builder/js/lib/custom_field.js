var Jsonable = require('../mixins/jsonable');

var CustomField = Ember.Object.extend(Jsonable, { 
  modified_at : new Date(),
  name        : '',
  value       : '',

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes('name', 'value'),

  getJson: function() {
    return {
      name: this.get('name'),
      value: this.get('value')
    }
  }
});

module.exports = CustomField;