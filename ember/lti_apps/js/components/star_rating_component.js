var StarRatingComponent = Ember.Component.extend({
  tagName: 'span',
  classNames: ['stars', 'pull-right'],
  
  didInsertElement: function() {
    console.log(this.get('stars'));
    var val = parseFloat(this.get('stars'));
    
    // Make sure that the value is in 0 - 5 range, multiply to get width
    var size = Math.max(0, (Math.min(5, val))) * 16;
    
    // Create stars holder
    var $span = $('<span/>').width(size);
    
    this.$().html($span);
  }
});

module.exports = StarRatingComponent;

