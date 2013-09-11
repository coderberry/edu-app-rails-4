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
        platform: this.get('platform'),
        filter: this.get('filter')
      }});
    });
  }.observes('category', 'education_level', 'platform', 'filter'),

  reset: function() {
    this.setProperties({
      filter: null,
      category: null,
      education_level: null,
      platform: null,
      filterText: null
    });
  },

  actions: {
    applyFilter: function() {
      if (Em.isEmpty(this.get('filterText'))) {
        this.set('filter', null);
      } else {
        this.set('filter', this.get('filterText'));
      }
    },

    reset: function() {
      Em.run.once(this, function() {
        this.reset();
      });
    }
  }
});

module.exports = IndexController;
