App.ApplicationController = Ember.ObjectController.extend({
  buildXml: function() {
    Ember.debug("Building...");
  },

  addCustomField: function() {
    customField = App.CustomField.create();
    this.get('model').get('custom_fields').pushObject(customField);
  },

  removeCustomField: function(cf) {
    this.get('model').get('custom_fields').removeObject(cf);
  },

  showEditorButtonSettings: function() {
    return this.get('model.useEditorButton');
  }.observes('useEditorButton')
});