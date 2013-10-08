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
  text                : null,
  default_width       : null,
  default_height      : null,
  privacy_level       : null,
  domain              : null,
  custom_fields       : null,
  config_options      : null,
  editor_button       : null,
  resource_selection  : null,
  homework_submission : null,
  course_navigation   : null,
  account_navigation  : null,
  user_navigation     : null,

  launch_types: [
    "editor_button", "resource_selection", "homework_submission",
    "course_navigation", "account_navigation", "user_navigation"
  ],

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
    'title', 'description', 'icon_url', 'launch_url', 'tool_id', 'text', 'default_width',
    'default_height', 'privacy_level', 'domain', 'custom_fields.@each.modified_at', 'config_options.@each.modified_at',
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
    this.set('text',              data.get('text'));
    this.set('default_width',     data.get('default_width'));
    this.set('default_height',    data.get('default_height'));
    this.set('privacy_level',     data.get('privacy_level'));
    this.set('domain',            data.get('domain'));

    var launch_types = data.get('launch_types');
    for(var type in launch_types){
      this.get(type).setProperties(launch_types[type])
    }

    if (!Em.isEmpty(data.optional_launch_types)) {
      for (var i = 0; i < data.optional_launch_types.length; i++) {
        this.get(data.optional_launch_types[i]).set('is_optional', true);
      }
    }

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
      title                 : this.get('title'),
      description           : this.get('description'),
      icon_url              : this.get('icon_url'),
      launch_url            : this.get('launch_url'),
      tool_id               : this.get('tool_id'),
      text                  : this.get('text'),
      default_width         : this.get('default_width'),
      default_height        : this.get('default_height'),
      privacy_level         : this.get('privacy_level'),
      domain                : this.get('domain'),
      custom_fields         : [],
      // config_options        : [],
      optional_launch_types : [],
      launch_types          : {}
    };

    for (var i = 0; i < this.launch_types.length; i++) {
      if(this.get(this.launch_types[i]).enabled){
        var launch_type = this.get(this.launch_types[i]).getJson();
        if(launch_type.is_optional){
          delete launch_type.is_optional
          json.optional_launch_types.push(this.launch_types[i])
        }
        json.launch_types[this.launch_types[i]] = launch_type;
      }
    }

    this.get('custom_fields').forEach(function(cf) {
      json['custom_fields'].push(cf.getJson());
    });

    // this.get('config_options').forEach(function(co) {
    //   json['config_options'].push(co.getJson());
    // });

    return json;
  }
});

module.exports = Cartridge;