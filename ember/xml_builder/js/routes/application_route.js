var LtiAppConfiguration = require('../models/lti_app_configuration');

var ApplicationRoute = Ember.Route.extend({
  model: function() {
    return LtiAppConfiguration.fetchAll().then(function(records) {
      records.forEach(function(record) {
        Ember.run.next(record, function() {
          record.deserialize();
        });
      });
      return records;
    });
  },

  events: {
    new: function() {
      var lti_app_configuration = LtiAppConfiguration.create({ uid: 'new' });
      this.transitionTo('lti_app_configuration', lti_app_configuration);
    }
  }
});

module.exports = ApplicationRoute;

