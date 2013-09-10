var LtiAppConfiguration = require('../models/lti_app_configuration');
var X2JS = require('../vendor/xml2json');
require('../vendor/vkbeautify.0.99.00.beta');

var ApplicationController = Ember.ArrayController.extend({
  needs: ['lti_app_configuration'],
  importUrl: '',
  pastedXml: '',
  xml: '',

  // computed properties ........................................................................
  
  showForm: function() {
    var ctrl = this.get('controllers.lti_app_configuration');
    return !Ember.isEmpty(ctrl.get('model'));
  }.property('controllers.lti_app_configuration.model'),

  config: function() {
    if (this.get('showForm')) {
      var raw_json = this.get('controllers.lti_app_configuration.cartridge').getJson();
      var json = JSON.stringify(raw_json, null, 2);
      return json;
    }
  }.property('controllers.lti_app_configuration.cartridge.modified_at'),

  // functions ..................................................................................

  showXml: function(record) {
    window.open('/configurations/' + record.get('uid') + '.xml', '_blank');
  },

  import: function() {
    _this = this;
    Ember.$.post('/api/v1/lti_app_configurations/import', { url: this.get('importUrl') }).then(function(data) {
      _this.get('model').reload();
      App.FlashQueue.pushFlash('notice', 'Successfully created configuration');
      _this.transitionToRoute('/' + data['lti_app_configuration']['uid']);
      _this.hideImportForm();
    });
  },

  createFromXml: function() {
    _this = this;
    Ember.$.post('/api/v1/lti_app_configurations/create_from_xml', { xml: this.get('pastedXml') }).then(
      function(data) {
        _this.get('model').reload();
        App.FlashQueue.pushFlash('notice', 'Successfully created configuration');
        _this.transitionToRoute('/' + data['lti_app_configuration']['uid']);
        _this.hideCreateFromXmlForm();
      },
      function(err) {
        App.FlashQueue.pushFlash('error', 'Invalid XML');
      }
    );
  },

  // actions ....................................................................................

  actions: {
    displayCreateFromXmlForm: function() {
      this.displayCreateFromXmlForm();
    },

    hideCreateFromXmlForm: function() {
      this.hideCreateFromXmlForm();
    },

    displayImportForm: function() {
      this.displayImportForm();
    },

    hideImportForm: function() {
      this.hideImportForm();
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
        ctrl.set('model', null);
        this.transitionToRoute('/');
      }
    },
  },

  displayImportForm: function() {
    this.hideCreateFromXmlForm();
    Ember.$('#import-panel').slideDown();
    Ember.$('#import-panel input[type="text"]').focus();
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

  hideImportForm: function() {
    Ember.$('#import-panel').slideUp();
    Ember.$('#import-panel input[type="text"]').val('');
  },

  // table sorting ..............................................................................

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
  }

});

module.exports = ApplicationController;

