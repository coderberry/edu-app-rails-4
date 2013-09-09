var Jsonable = require('../mixins/jsonable');

var ConfigOption = Ember.Object.extend(Jsonable, { 
  modified_at   : new Date(),
  name          : '',
  description   : '',
  type          : 'text',
  default_value : '',
  is_required   : false,

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes('name', 'description', 'type', 'default_value', 'is_required'),

  getJson: function() {
    return {
      name          : this.get('name'),
      description   : this.get('description'),
      type          : this.get('type'),
      default_value : this.get('default_value'),
      is_required   : this.get('is_required')
    }
  }
});

module.exports = ConfigOption;