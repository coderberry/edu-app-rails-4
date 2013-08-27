var Jsonable                 = require('../mixins/jsonable');
var ConfigOption             = require('./config_option');
var CustomField              = require('./custom_field');
var CustomButtonSettings     = require('./custom_button_settings');
var CustomNavigationSettings = require('./custom_navigation_settings');

var Cartridge = Ember.Object.extend(Jsonable, { 
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

  getErrors: function() {
    var errors = {};
    if (Ember.isEmpty(this.get('title'))) {
      errors['title'] = 'must be present';
    }
    if (Ember.isEmpty(this.get('launchUrl'))) {
      errors['launchUrl'] = 'must be present';
    }
    if (!Ember.isNone(errors)) {
      return Ember.Object.create(errors);
    }
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

    this.get('configOptions').clear();
    data.get('configOptions').forEach(function(opt) {
      _this.get('configOptions').pushObject(ConfigOption.create(opt));
    });

    this.get('customFields').clear();
    data.get('customFields').forEach(function(cf) {
      _this.get('customFields').pushObject(CustomField.create(cf));
    });
  }
});

module.exports = Cartridge;