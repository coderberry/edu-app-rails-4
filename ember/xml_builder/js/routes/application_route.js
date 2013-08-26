var LtiAppConfiguration = require('../models/lti_app_configuration');

var ApplicationRoute = Ember.Route.extend({
  model: function() {
    return LtiAppConfiguration.findAll();
  },

  events: {
    new: function() {
      var lti_app_configuration = LtiAppConfiguration.create({ uid: 'new' });
      this.transitionTo('lti_app_configuration', lti_app_configuration);
    }
  }
});

module.exports = ApplicationRoute;

