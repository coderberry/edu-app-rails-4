var ConfigOption = require('../lib/config_option');
var CustomField = require('../lib/custom_field');

var LtiAppConfigurationController = Ember.ObjectController.extend({

  // popoverObserver: function() {
  //   Ember.run.next(this, function() {
  //     Em.$('*[data-toggle="popover"]').popover({
  //       container: 'body', 
  //       trigger: 'focus'
  //     });
  //   });
  // }.observes('useEditorButton', 'useLinkSelection', 'useHomeworkSubmission', 'useCourseNavigation', 
  //            'useAccountNavigation', 'useUserNavigation', 'custom_fields.@each'),

  addConfigOption: function() {
    configOption = ConfigOption.create();
    this.get('model').get('cartridge.configOptions').pushObject(configOption);
  },

  addCustomField: function() {
    customField = CustomField.create();
    this.get('model').get('cartridge.customFields').pushObject(customField);
  },

  removeConfigOption: function(co) {
    this.get('model').get('cartridge.configOptions').removeObject(co);
  },

  removeCustomField: function(cf) {
    this.get('model').get('cartridge.customFields').removeObject(cf);
  }
});

module.exports = LtiAppConfigurationController;

