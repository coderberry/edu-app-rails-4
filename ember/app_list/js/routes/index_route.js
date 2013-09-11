var IndexRoute = Ember.Route.extend({
  setupController: function(controller, context, queryParams) {
    this.get('store').findQuery('lti_app', queryParams).then(function(apps) {
      controller.set('model', apps);
    });
    controller.set('category', queryParams.category);
    controller.set('education_level', queryParams.education_level);
    controller.set('platform', queryParams.platform);
    controller.set('filter', queryParams.filter);
    controller.set('filterText', queryParams.filter);
  }
});

module.exports = IndexRoute;

