// require('../vendor/jquery');
require('../vendor/handlebars');
require('../vendor/ember');
require('../vendor/ember-data');

Ember.FEATURES["query-params"] = true;

var App = Ember.Application.create({
  rootElement: '#ember-app',
  LOG_TRANSITIONS: true,
  LOG_TRANSITIONS_INTERNAL: true
});
App.Store = require('./store');

module.exports = App;

