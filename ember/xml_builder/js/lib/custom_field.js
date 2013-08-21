var CustomField = Ember.Object.extend({ 
  name        : '',
  description : '',
  type        : 'text',
  value       : '',
  required    : false,

  modifiedAt: function() {
    return new Date();
  }.property('name', 'description', 'type', 'value', 'required')
});

module.exports = CustomField;