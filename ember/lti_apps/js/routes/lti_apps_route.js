var LtiApp = require('../models/lti_app');

var LtiAppsRoute = Ember.Route.extend({
  model: function() {
    return LtiApp.find();
  },

  events: {
    show: function(lti_app) {
      window.location = "/apps/" + lti_app.get('short_name');
    }
  }
});

module.exports = LtiAppsRoute;

