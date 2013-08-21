var Cartridge = require('../models/cartridge');

var CartridgeRoute = Ember.Route.extend({
  model: function(params) {
    var _this = this;
    if (params.uid === 'new') {
      var c = Cartridge.create({ uid: 'new', custom_fields: [] });
      _this.transitionTo('cartridge', c);
    } else {
      return Cartridge.fetch(params.uid).then(
        function(record) {
          Ember.run.next(record, function() {
            record.deserialize();
          });
          return record;
        },
        function(err) {
          var c = Cartridge.create({ uid: 'new', custom_fields: [] });
          _this.transitionTo('cartridge', c);
        }
      );
    }
  },

  setupController: function(controller, model) {
    var uid = model.get('uid');
    if (uid === 'new') {
      controller.set('model', Cartridge.create({ custom_fields: [] }));
    } else {
      var cartridge = Cartridge.find(model.get('uid'));
      controller.set('model', cartridge);
    }
  },

  serialize: function(model) {
    return { uid: model.get('uid') };
  }
});

module.exports = CartridgeRoute;
