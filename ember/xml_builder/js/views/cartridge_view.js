var CartridgeView = Ember.View.extend({
  didInsertElement: function() {
    Em.$('*[data-toggle="popover"]').popover({
      container: 'body', 
      trigger: 'focus'
    });
  }
});

module.exports = CartridgeView;

