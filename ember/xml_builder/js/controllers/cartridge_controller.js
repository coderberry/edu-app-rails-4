var CustomField = require('../lib/custom_field');

var CartridgeController = Ember.ObjectController.extend({
  addCustomField: function() {
    customField = CustomField.create();
    this.get('model').get('custom_fields').pushObject(customField);
  },

  removeCustomField: function(cf) {
    this.get('model').get('custom_fields').removeObject(cf);
  }
});

module.exports = CartridgeController;

