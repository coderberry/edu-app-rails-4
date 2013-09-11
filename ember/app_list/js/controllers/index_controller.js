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

  sortFields: [
    Ember.Object.create({ active: true, key: 'name', value: "Alphabetic" }), 
    Ember.Object.create({ active: false, key: 'rating', value: "Highest Rated" }), 
    // Ember.Object.create({ active: false, key: 'popular', value: "Most Popular" }),
    Ember.Object.create({ active: false, key: 'recent', value: "Most Recent" })
  ],

  filtersChanged: function() {
    Em.run.once(this, function() {
      this.transitionToRoute({ queryParams: { 
        category: this.get('category'),
        education_level: this.get('education_level'),
        platform: this.get('platform'),
        filter: this.get('filter'),
        sort: this.get('sort')
      }});
    });
  }.observes('category', 'education_level', 'platform', 'filter', 'sort'),

  reset: function() {
    this.setProperties({
      filter: null,
      category: null,
      education_level: null,
      platform: null,
      filterText: null
    });
  },

  setActiveSortField: function(k) {
    this.get('sortFields').setEach('active', false);
    this.get('sortFields').findProperty('key', k).set('active', true);
  },

  actions: {
    applyFilter: function() {
      if (Em.isEmpty(this.get('filterText'))) {
        this.set('filter', null);
      } else {
        this.set('filter', this.get('filterText'));
      }
    },

    sort: function(k) {
      this.set('sort', k);
      this.setActiveSortField(k);
    },

    reset: function() {
      Em.run.once(this, function() {
        this.reset();
      });
    }
  }
});

module.exports = IndexController;
