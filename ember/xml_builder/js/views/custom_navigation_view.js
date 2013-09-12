var CustomNavigationView = Ember.View.extend({
  templateName: "_custom_navigation",

  displayName: function() {
    return this.get('content.name').replace(/_/g, ' ')
               .replace(/(\w+)/g, function(match) {
                 return match.charAt(0).toUpperCase() + match.slice(1);
               });
  }.property('content.name'),

  displayExtras: function() {
    return (this.get('content.name') === 'course_navigation');
  }.property('content.name')
});

module.exports = CustomNavigationView;

