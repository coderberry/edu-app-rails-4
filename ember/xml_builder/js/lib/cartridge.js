var Jsonable                 = require('../mixins/jsonable');
var ConfigOption             = require('./config_option');
var CustomField              = require('./custom_field');
var CustomButtonSettings     = require('./custom_button_settings');
var CustomNavigationSettings = require('./custom_navigation_settings');

var Cartridge = Ember.Object.extend(Ember.Validations.Mixin, {
  title              : null,
  description        : null,
  iconUrl            : null,
  launchUrl          : null,
  toolId             : null,
  defaultLinkText    : null,
  defaultWidth       : null,
  defaultHeight      : null,
  launchPrivacy      : null,
  domain             : null,
  customFields       : null,
  configOptions      : null,
  editorButton       : null,
  resourceSelection  : null,
  homeworkSubmission : null,
  courseNav          : null,
  accountNav         : null,
  userNav            : null,

  // Validations
  validations: {
    title: {
      presence: true
    },
    launchUrl: {
      format: { with: /^https?:\/\/.+$/, message: 'must be a valid URL (with http:// or https://)'  }
    },
    toolId: {
      format: { with: /^[a-z_]{3,}$/, message: 'must be one word, all lowercase with underscores (e.g. my_app)' }
    },
    iconUrl: {
      format: { with: /^https?:\/\/.+$/, allowBlank: true, message: 'must be a valid image URL (with http:// or https://)'  }
    },
    defaultWidth: {
      numericality: { onlyInteger: true, greaterThan: 0, allowBlank: true }
    },
    defaultHeight: {
      numericality: { onlyInteger: true, greaterThan: 0, allowBlank: true }
    }
  },

  modifiedAt: function() {
    return new Date();
  }.property(
    'title', 'description', 'iconUrl', 'launchUrl', 'toolId', 'defaultLinkText', 'defaultWidth', 
    'defaultHeight', 'launchPrivacy', 'domain', 'customFields.@each.modifiedAt', 'configOptions.@each.modifiedAt', 
    'editorButton.modifiedAt', 'resourceSelection.modifiedAt', 'homeworkSubmission.modifiedAt', 
    'courseNav.modifiedAt', 'accountNav.modifiedAt', 'userNav.modifiedAt'),
  
  init: function() {
    this._super();
    this.set('editorButton',       CustomButtonSettings.create({ name: 'editor_button' }));
    this.set('resourceSelection',  CustomButtonSettings.create({ name: 'resource_selection' }));
    this.set('homeworkSubmission', CustomButtonSettings.create({ name: 'homework_submission' }));
    this.set('courseNav',          CustomNavigationSettings.create({ name: 'course_nav' }));
    this.set('accountNav',         CustomNavigationSettings.create({ name: 'account_nav' }));
    this.set('userNav',            CustomNavigationSettings.create({ name: 'user_nav' }));
    this.set('customFields',       []);
    this.set('configOptions',      []);
  },

  populateWith: function(stringifiedJson) {
    var data = Ember.Object.create(JSON.parse(stringifiedJson));

    var _this = this;

    this.set('title',           data.get('title'));
    this.set('description',     data.get('description'));
    this.set('iconUrl',         data.get('iconUrl'));
    this.set('launchUrl',       data.get('launchUrl'));
    this.set('toolId',          data.get('toolId'));
    this.set('defaultLinkText', data.get('defaultLinkText'));
    this.set('defaultWidth',    data.get('defaultWidth'));
    this.set('defaultHeight',   data.get('defaultHeight'));
    this.set('launchPrivacy',   data.get('launchPrivacy'));
    this.set('domain',          data.get('domain'));

    this.get('editorButton').setProperties(data.get('editorButton'));
    this.get('resourceSelection').setProperties(data.get('resourceSelection'));
    this.get('homeworkSubmission').setProperties(data.get('homeworkSubmission'));
    this.get('courseNav').setProperties(data.get('courseNav'));
    this.get('accountNav').setProperties(data.get('accountNav'));
    this.get('userNav').setProperties(data.get('userNav'));

    this.set('configOptions', []);
    if (!Ember.isEmpty(data.get('configOptions'))) {
      Em.$.each(data.get('configOptions'), function(idx, opt) {
        _this.get('configOptions').pushObject(ConfigOption.create(opt));
      });
    }

    this.set('customFields', []);
    if (!Ember.isEmpty(data.get('customFields'))) {
      Em.$.each(data.get('customFields'), function(idx, cf) {
        _this.get('customFields').pushObject(CustomField.create(cf));
      });
    }
  },

  getJson: function() {
    return {
      title              : this.get('title'),
      description        : this.get('description'),
      iconUrl            : this.get('iconUrl'),
      launchUrl          : this.get('launchUrl'),
      toolId             : this.get('toolId'),
      defaultLinkText    : this.get('defaultLinkText'),
      defaultWidth       : this.get('defaultWidth'),
      defaultHeight      : this.get('defaultHeight'),
      launchPrivacy      : this.get('launchPrivacy'),
      domain             : this.get('domain'),
      customFields       : this.get('customFields'),
      configOptions      : this.get('configOptions'),
      editorButton       : this.get('editorButton'),
      resourceSelection  : this.get('resourceSelection'),
      homeworkSubmission : this.get('homeworkSubmission'),
      courseNav          : this.get('courseNav'),
      accountNav         : this.get('accountNav'),
      userNav            : this.get('userNav'),
    };
  }
});

module.exports = Cartridge;