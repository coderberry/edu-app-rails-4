var ConfigOption = require('../lib/config_option');
var CustomField = require('../lib/custom_field');

var LtiAppConfigurationController = Ember.ObjectController.extend({

  addConfigOption: function() {
    configOption = ConfigOption.create();
    this.get('model').get('config_options').pushObject(configOption);
  },

  addCustomField: function() {
    customField = CustomField.create();
    this.get('model').get('custom_fields').pushObject(customField);
  },

  popoverObserver: function() {
    Ember.run.next(this, function() {
      Em.$('*[data-toggle="popover"]').popover({
        container: 'body', 
        trigger: 'focus'
      });
    });
  }.observes('useEditorButton', 'useLinkSelection', 'useHomeworkSubmission', 'useCourseNavigation', 
             'useAccountNavigation', 'useUserNavigation', 'custom_fields.@each'),

  removeConfigOption: function(co) {
    this.get('model').get('config_options').removeObject(co);
  },

  removeCustomField: function(cf) {
    this.get('model').get('custom_fields').removeObject(cf);
  }
});

module.exports = LtiAppConfigurationController;

