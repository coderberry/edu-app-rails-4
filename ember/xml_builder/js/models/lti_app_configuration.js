var attr                     = Ember.attr;
var Cartridge                = require('../lib/cartridge');

var LtiAppConfiguration = Ember.Model.extend({
  isDeserializing: false,

  // persisting attributes
  uid                        : attr(),     // string
  created_at                 : attr(Date), // datetime
  updated_at                 : attr(Date), // datetime
  config                     : attr(),     // stringified json
  name                       : attr(),     // string (not persisted)
  icon                       : attr(),     // string (not persisted)

  // cartridge object which contains all form data
  cartridge                  : null,

  // ensure that there is a cartridge
  init: function() {
    this._super();
    this.set('cartridge', Cartridge.create());
  },

  // extract the data from config and populate the cartridge
  deserialize: function() {
    if (!Ember.isEmpty(this.get('config'))) {
      this.get('cartridge').populateWith(this.get('config'));
    }
  },

  // update the cartridge with the stringified JSON then save
  persist: function() {
    var _this = this;
    var cartridge = this.get('cartridge');
    cartridge.validate().then(
      function() {
        var url = '/api/v1/lti_app_configurations';
        var uid = _this.get('uid');
        if (!Ember.isEmpty(uid) && (uid !== 'new')) {
          url = '/api/v1/lti_app_configurations/' + uid;
        }
        var configStr = JSON.stringify(_this.get('cartridge').getJson());
        Ember.$.post(url, { config: configStr })
        .done(function(data) {
          if (data['lti_app_configuration']) {
            _this.set('uid',        data['lti_app_configuration']['uid']);
            _this.set('name',       data['lti_app_configuration']['name']);
            _this.set('icon',       data['lti_app_configuration']['icon']);
            _this.set('config',     data['lti_app_configuration']['config']);
            _this.set('created_at', Date.parse(data['lti_app_configuration']['created_at']));
            _this.set('updated_at', Date.parse(data['lti_app_configuration']['updated_at']));
            _this.trigger('didSaveRecord');
          }
          App.FlashQueue.pushFlash('notice', 'Your cartridge has been saved!');
        }, 'json')
        .fail(function(err) {
          App.FlashQueue.pushFlash('error', 'Please correct the fields below');
        });
      }, 
      function() { 
        App.FlashQueue.pushFlash('error', 'Please correct the fields below');
      }
    );
  }

}).reopenClass({
  rootKey       : 'lti_app_configuration',
  collectionKey : 'lti_app_configurations',
  url           : '/api/v1/lti_app_configurations',
  adapter       : Ember.RESTAdapter.create()
});

module.exports = LtiAppConfiguration;