var Cartridge = require('../models/cartridge');

var ApplicationRoute = Ember.Route.extend({
  model: function() {
    return Cartridge.findAll();
  },

  events: {
    new: function() {
      var cartridge = Cartridge.create({ uid: 'new', custom_fields: [] });
      this.transitionTo('cartridge', cartridge);
    }
  }
});

module.exports = ApplicationRoute;

