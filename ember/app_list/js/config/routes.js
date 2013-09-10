var App = require('./app');

App.Router.map(function() {
  this.route('index', { path: '/', queryParams: ['category', 'education_level', 'platform', 'filter'] });
});

