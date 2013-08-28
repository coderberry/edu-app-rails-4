var FormGroupView = Ember.View.extend({
  tagName: 'div',
  classNameBindings: [':form-group', 'hasError:has-error'],

  hasError: function() {
    return (!Ember.isEmpty(this.get('error')));
  }.property('error')
});

module.exports = FormGroupView;

