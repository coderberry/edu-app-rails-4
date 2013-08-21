var Cartridge = require('../models/cartridge');
var X2JS = require('../vendor/xml2json');
require('../vendor/vkbeautify.0.99.00.beta');

var ApplicationController = Ember.ArrayController.extend({
  needs: ['cartridge'],
  importUrl: '',
  pastedXml: '',

  sortedColumn: (function() {
    var properties = this.get('sortProperties');
    if(!properties) return undefined;
    return properties.get('firstObject');
  }).property('sortProperties.[]'),

  columns: (function() {
   return [
     Ember.Object.create({name: 'name', label: 'Name'}),
     Ember.Object.create({name: 'updated_at', label: 'Modified'})
    ];
  }).property(),

  toggleSort: function(column) {
    if(this.get('sortedColumn') == column) {
      this.toggleProperty('sortAscending');
    } else {
      this.set('sortProperties', [column]);
      this.set('sortAscending', true);
    }
  },

  showForm: function() {
    var cartridgeCtrl = this.get('controllers.cartridge');
    return !Ember.isEmpty(cartridgeCtrl.get('model'));
  }.property('controllers.cartridge.model'),

  showXml: function(record) {
    window.open('/cartridges/' + record.get('uid') + '.xml', '_blank');
  },

  import: function() {
    _this = this;
    Ember.$.post('/api/v1/cartridges/import', { url: this.get('importUrl') }).then(function(data) {
      _this.get('model').reload();
      App.FlashQueue.pushFlash('notice', 'Successfully imported ' + data['cartridge']['name']);
      _this.transitionToRoute('/' + data['cartridge']['uid']);
      _this.hideImportForm();
    });
  },

  createFromXml: function() {
    _this = this;
    Ember.$.post('/api/v1/cartridges/create_from_xml', { xml: this.get('pastedXml') }).then(
      function(data) {
        _this.get('model').reload();
        App.FlashQueue.pushFlash('notice', 'Successfully created ' + data['cartridge']['name']);
        _this.transitionToRoute('/' + data['cartridge']['uid']);
        _this.hideCreateFromXmlForm();
      },
      function(err) {
        App.FlashQueue.pushFlash('error', 'Invalid XML');
      }
    );
  },

  displayImportForm: function() {
    this.hideCreateFromXmlForm();
    Ember.$('#import-panel').slideDown();
    Ember.$('#import-panel input[type="text"]').focus();
  },

  hideImportForm: function() {
    Ember.$('#import-panel').slideUp();
    Ember.$('#import-panel input[type="text"]').val('');
  },

  displayCreateFromXmlForm: function() {
    this.hideImportForm();
    Ember.$('#create-from-xml-panel').slideDown();
    Ember.$('#create-from-xml-panel textarea').focus();
  },

  hideCreateFromXmlForm: function() {
    Ember.$('#create-from-xml-panel').slideUp();
    Ember.$('#create-from-xml-panel textarea').html('');
  },

  save: function() {
    var _this = this;
    var cartridgeCtrl = this.get('controllers.cartridge');
    var cartridge = cartridgeCtrl.get('model');

    cartridge.on('didSaveRecord', function() {
      _this.get('model').reload();
      _this.transitionToRoute('cartridge', cartridge);
    });

    cartridge.persist();
  },

  delete: function(record) {
    if (!confirm("Are you sure?")) return;

    var cartridgeCtrl = this.get('controllers.cartridge');
    var cartridge = cartridgeCtrl.get('model');
    var isCurrentRecord = false;
    if (cartridge) {
      isCurrentRecord = (cartridge.get('id') === record.get('uid'));
    }

    record.deleteRecord();
    App.FlashQueue.pushFlash('notice', 'Cartridge has been deleted');

    this.get('model').reload();
    if (isCurrentRecord) {
      this.send('new');
    }
  },

  xml: function() {
    var compressed_xml = this.get('controllers.cartridge.xml');
    if (!Ember.isEmpty(compressed_xml)) {
      var code = vkbeautify.xml(compressed_xml, 2);
      return code;
    }
  }.property('controllers.cartridge.xml')

});

module.exports = ApplicationController;

