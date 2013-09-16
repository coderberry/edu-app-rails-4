var App = require('./app');

App.Router.map(function() {
  this.route('facebook', { path: '_=_.index' }); // Facebook messes with the URL after authentication
  this.route('index', { path: '/', queryParams: ['category', 'education_level', 'platform', 'filter', 'sort'] });
});

App.FacebookRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('index');
  }
});