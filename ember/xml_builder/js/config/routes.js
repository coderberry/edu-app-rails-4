var App = require('./app');

App.Router.map(function() {
  this.resource('lti_app_configurations', { path: '/' }, function() {
    this.resource('lti_app_configuration', { path: '/:uid' });
  });
});

