var Jsonable = require('../mixins/jsonable');

var CustomField = Ember.Object.extend(Jsonable, { 
  modifiedAt : new Date(),
  name       : '',
  value      : '',

  changeObserver: function() {
    this.set('modifiedAt', new Date());
  }.observes('name', 'value'),

  getJson: function() {
    return {
      name: this.get('name'),
      value: this.get('value')
    }
  }
});

module.exports = CustomField;