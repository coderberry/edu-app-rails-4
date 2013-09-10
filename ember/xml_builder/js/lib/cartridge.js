var Jsonable                 = require('../mixins/jsonable');
var ConfigOption             = require('./config_option');
var CustomField              = require('./custom_field');
var CustomButtonSettings     = require('./custom_button_settings');
var CustomNavigationSettings = require('./custom_navigation_settings');

var Cartridge = Ember.Object.extend(Ember.Validations.Mixin, {
  modified_at         : new Date(),
  title               : null,
  description         : null,
  icon_url            : null,
  launch_url          : null,
  tool_id             : null,
  default_link_text   : null,
  default_width       : null,
  default_height      : null,
  launch_privacy      : null,
  domain              : null,
  custom_fields       : null,
  config_options      : null,
  editor_button       : null,
  resource_selection  : null,
  homework_submission : null,
  course_navigation   : null,
  account_navigation  : null,
  user_navigation     : null,

  // Validations
  validations: {
    title: {
      presence: true
    },
    launch_url: {
      format: { with: /^https?:\/\/.+$/, message: 'must be a valid URL (with http:// or https://)'  }
    },
    tool_id: {
      format: { with: /^[a-z_]{3,}$/, message: 'must be one word, all lowercase with underscores (e.g. my_app)' }
    },
    icon_url: {
      format: { with: /^https?:\/\/.+$/, allowBlank: true, message: 'must be a valid image URL (with http:// or https://)'  }
    },
    default_width: {
      numericality: { onlyInteger: true, greaterThan: 0, allowBlank: true }
    },
    default_height: {
      numericality: { onlyInteger: true, greaterThan: 0, allowBlank: true }
    }
  },

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes(
    'title', 'description', 'icon_url', 'launch_url', 'tool_id', 'default_link_text', 'default_width',
    'default_height', 'launch_privacy', 'domain', 'custom_fields.@each.modified_at', 'config_options.@each.modified_at', 
    'editor_button.modified_at', 'resource_selection.modified_at', 'homework_submission.modified_at', 
    'course_navigation.modified_at', 'account_navigation.modified_at', 'user_navigation.modified_at'),
  
  init: function() {
    this._super();
    this.set('editor_button',       CustomButtonSettings.create({ name: 'editor_button' }));
    this.set('resource_selection',  CustomButtonSettings.create({ name: 'resource_selection' }));
    this.set('homework_submission', CustomButtonSettings.create({ name: 'homework_submission' }));
    this.set('course_navigation',   CustomNavigationSettings.create({ name: 'course_navigation' }));
    this.set('account_navigation',  CustomNavigationSettings.create({ name: 'account_navigation' }));
    this.set('user_navigation',     CustomNavigationSettings.create({ name: 'user_navigation' }));
    this.set('custom_fields',       []);
    this.set('config_options',      []);
  },

  populateWith: function(stringifiedJson) {
    var data = Ember.Object.create(JSON.parse(stringifiedJson));

    var _this = this;

    this.set('title',             data.get('title'));
    this.set('description',       data.get('description'));
    this.set('icon_url',          data.get('icon_url'));
    this.set('launch_url',        data.get('launch_url'));
    this.set('tool_id',           data.get('tool_id'));
    this.set('default_link_text', data.get('default_link_text'));
    this.set('default_width',     data.get('default_width'));
    this.set('default_height',    data.get('default_height'));
    this.set('launch_privacy',    data.get('launch_privacy'));
    this.set('domain',            data.get('domain'));

    this.get('editor_button').setProperties(data.get('editor_button'));
    this.get('resource_selection').setProperties(data.get('resource_selection'));
    this.get('homework_submission').setProperties(data.get('homework_submission'));
    this.get('course_navigation').setProperties(data.get('course_navigation'));
    this.get('account_navigation').setProperties(data.get('account_navigation'));
    this.get('user_navigation').setProperties(data.get('user_navigation'));

    this.set('config_options', []);
    if (!Ember.isEmpty(data.get('config_options'))) {
      Em.$.each(data.get('config_options'), function(idx, opt) {
        _this.get('config_options').pushObject(ConfigOption.create(opt));
      });
    }

    this.set('custom_fields', []);
    if (!Ember.isEmpty(data.get('custom_fields'))) {
      Em.$.each(data.get('custom_fields'), function(idx, cf) {
        _this.get('custom_fields').pushObject(CustomField.create(cf));
      });
    }
  },

  getJson: function() {
    var json = {
      title               : this.get('title'),
      description         : this.get('description'),
      icon_url            : this.get('icon_url'),
      launch_url          : this.get('launch_url'),
      tool_id             : this.get('tool_id'),
      default_link_text   : this.get('default_link_text'),
      default_width       : this.get('default_width'),
      default_height      : this.get('default_height'),
      launch_privacy      : this.get('launch_privacy'),
      domain              : this.get('domain'),
      custom_fields       : [],
      config_options      : [],
      editor_button       : this.get('editor_button').getJson(),
      resource_selection  : this.get('resource_selection').getJson(),
      homework_submission : this.get('homework_submission').getJson(),
      course_navigation   : this.get('course_navigation').getJson(),
      account_navigation  : this.get('account_navigation').getJson(),
      user_navigation     : this.get('user_navigation').getJson()
    };

    this.get('custom_fields').forEach(function(cf) {
      json['custom_fields'].push(cf.getJson());
    });

    this.get('config_options').forEach(function(co) {
      json['config_options'].push(co.getJson());
    });

    return json;
  }
});

module.exports = Cartridge;