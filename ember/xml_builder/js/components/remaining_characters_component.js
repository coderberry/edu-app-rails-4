var RemainingCharactersComponent = Ember.Component.extend({
  tagName: 'span',
  classNameBindings: 'className',
  body: '',
  max: 250,

  remaining: function() {
    var bodyLen = (this.get('body') || '').length;
    var maxLen = this.get('max');
    return maxLen - bodyLen;
  }.property('body', 'max'),

  className: function() {
    var remaining = this.get('remaining');
    if (remaining > 100) {
      return "text-success";
    } else if (remaining > 25) {
      return "text-info";
    } else if (remaining > 0) {
      return "text-warning";
    } else {
      return "text-danger";
    }
  }.property('remaining')
});

module.exports = RemainingCharactersComponent;
