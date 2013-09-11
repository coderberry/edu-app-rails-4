var InstructureStarsComponent = Ember.Component.extend({
  tagName: 'span',
  classNames: 'stars',
  
  display: function() {
    var val = this.get('value');

    // Make sure that the value is in 0 - 5 range, multiply to get width
    var size = Math.max(0, (Math.min(5, val))) * 16;
    
    // Create stars holder
    var $span = $('<span/>').width(size);
    
    this.$().html($span);
  }.on('didInsertElement')
});

module.exports = InstructureStarsComponent;

