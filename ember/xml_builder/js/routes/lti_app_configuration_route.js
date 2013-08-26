var LtiAppConfiguration = require('../models/lti_app_configuration');

var LtiAppConfigurationRoute = Ember.Route.extend({

  model: function(params) {
    console.log("MODEL");
    var _this = this;
    if (params.uid === 'new') {
      var c = LtiAppConfiguration.create({ uid: 'new' });
      _this.transitionTo('lti_app_configuration', c);
    } else {
      return LtiAppConfiguration.fetch(params.uid).then(
        function(record) {
          // Ember.run.next(record, function() {
          //   record.deserialize();
          // });
          // return record;
          _this.transitionTo('lti_app_configuration', record);
        },
        function(err) {
          var c = LtiAppConfiguration.create({ uid: 'new' });
          _this.transitionTo('lti_app_configuration', c);
        }
      );
    }
  },

  setupController: function(controller, model) {
    console.log("SETUP CONTROLLER");
    var uid = model.get('uid');
    if (uid === 'new') {
      var c = LtiAppConfiguration.create({ uid: 'new' });
      Ember.run.next(c, function() {
        c.deserialize();
      });
      controller.set('model', c);
    } else {
      var c = LtiAppConfiguration.fetch(model.get('uid')).then(
        function(record) {
          Ember.run.next(record, function() {
            record.deserialize();
          });
          controller.set('model', record);
        },
        function(err) {
          var c = LtiAppConfiguration.create({ uid: 'new' });
          Ember.run.next(c, function() {
            c.deserialize();
          });
          controller.set('model', c);
        }
      );
    }
  },

  serialize: function(model) {
    return { uid: model.get('uid') };
  }
});

module.exports = LtiAppConfigurationRoute;

