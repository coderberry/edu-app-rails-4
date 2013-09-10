var IndexController = Ember.ArrayController.extend({
  categories: function() {
    return Ember.ENV['categories'];
  }.property(),

  education_levels: function() {
    return Ember.ENV['education_levels'];
  }.property(),

  platforms: function() {
    return Ember.ENV['platforms'];
  }.property(),

  filtersChanged: function() {
    Em.run.once(this, function() {
      this.transitionToRoute({ queryParams: { 
        category: this.get('category'),
        education_level: this.get('education_level'),
        platform: this.get('platform')
      }});
    });
  }.observes('category', 'education_level', 'platform')
});

module.exports = IndexController;
