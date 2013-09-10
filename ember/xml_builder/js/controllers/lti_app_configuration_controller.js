var ConfigOption = require('../lib/config_option');
var CustomField = require('../lib/custom_field');

var LtiAppConfigurationController = Ember.ObjectController.extend({
  actions: {
    addConfigOption: function() {
      configOption = ConfigOption.create();
      this.get('model').get('cartridge.config_options').pushObject(configOption);
    },

    addCustomField: function() {
      customField = CustomField.create();
      this.get('model').get('cartridge.custom_fields').pushObject(customField);
    },

    removeConfigOption: function(co) {
      this.get('model').get('cartridge.config_options').removeObject(co);
    },

    removeCustomField: function(cf) {
      this.get('model').get('cartridge.custom_fields').removeObject(cf);
    }
  }
});

module.exports = LtiAppConfigurationController;

