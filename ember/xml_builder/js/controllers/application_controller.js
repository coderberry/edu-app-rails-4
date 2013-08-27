var LtiAppConfiguration = require('../models/lti_app_configuration');
var X2JS = require('../vendor/xml2json');
require('../vendor/vkbeautify.0.99.00.beta');

var ApplicationController = Ember.ArrayController.extend({
  needs: ['lti_app_configuration'],
  importUrl: '',
  pastedXml: '',

  showForm: function() {
    var ctrl = this.get('controllers.lti_app_configuration');
    return !Ember.isEmpty(ctrl.get('model'));
  }.property('controllers.lti_app_configuration.model'),

  showXml: function(record) {
    window.open('/configurations/' + record.get('uid') + '.xml', '_blank');
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
    var ctrl = this.get('controllers.lti_app_configuration');
    var ltiAppConfiguration = ctrl.get('model');

    ltiAppConfiguration.on('didSaveRecord', function() {
      _this.get('model').reload();
      _this.transitionToRoute('lti_app_configuration', ltiAppConfiguration);
    });

    ltiAppConfiguration.persist();
  },

  delete: function(record) {
    if (!confirm("Are you sure?")) return;

    var ctrl = this.get('controllers.lti_app_configuration');
    var lti_app_configuration = ctrl.get('model');
    var isCurrentRecord = false;
    if (lti_app_configuration) {
      isCurrentRecord = (lti_app_configuration.get('id') === record.get('uid'));
    }

    record.deleteRecord();
    App.FlashQueue.pushFlash('notice', 'Configuration has been deleted');

    this.get('model').reload();
    if (isCurrentRecord) {
      this.send('new');
    }
  },

  xml: function() {
    var compressed_xml = this.get('controllers.lti_app_configuration.xml');
    if (!Ember.isEmpty(compressed_xml)) {
      var code = vkbeautify.xml(compressed_xml, 2);
      return code;
    }
  }.property('controllers.lti_app_configuration.xml'),

  // Required functions for supporting sorting
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
});

module.exports = ApplicationController;

