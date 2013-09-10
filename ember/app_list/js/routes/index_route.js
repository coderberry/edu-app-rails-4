var IndexRoute = Ember.Route.extend({
  setupController: function(controller, context, queryParams) {
    controller.set('model', context);'category', 'education_level', 'platform', 'filter'
    controller.set('category', queryParams.category);
    controller.set('education_level', queryParams.education_level);
    controller.set('platform', queryParams.platform);
    controller.set('filter', queryParams.filter);
  }
});

module.exports = IndexRoute;

