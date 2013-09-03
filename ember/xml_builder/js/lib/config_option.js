var Jsonable = require('../mixins/jsonable');

var ConfigOption = Ember.Object.extend(Jsonable, { 
  modifiedAt   : new Date(),
  name         : '',
  description  : '',
  type         : 'text',
  defaultValue : '',
  isRequired   : false,

  changeObserver: function() {
    this.set('modifiedAt', new Date());
  }.observes('name', 'description', 'type', 'defaultValue', 'isRequired'),

  getJson: function() {
    return {
      name         : this.get('name'),
      description  : this.get('description'),
      type         : this.get('type'),
      defaultValue : this.get('defaultValue'),
      isRequired   : this.get('isRequired')
    }
  }
});

module.exports = ConfigOption;