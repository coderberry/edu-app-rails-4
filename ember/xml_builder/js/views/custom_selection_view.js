var CustomSelectionView = Ember.View.extend({
  templateName: "_custom_selection",

  displayName: function() {
    return this.get('content.name').replace(/_/g, ' ')
               .replace(/(\w+)/g, function(match) {
                 return match.charAt(0).toUpperCase() + match.slice(1);
               });
  }.property('content.name')
});

module.exports = CustomSelectionView;

