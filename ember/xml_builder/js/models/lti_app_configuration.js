var attr                     = Ember.attr;
var App                      = require('../config/app');
var ConfigOption             = require('../lib/config_option');
var CustomField              = require('../lib/custom_field');
var CustomButtonSettings     = require('../lib/custom_button_settings');
var CustomNavigationSettings = require('../lib/custom_navigation_settings');
var NavigationSettings       = require('../lib/navigation_settings');
var X2JS                     = require('../vendor/xml2json');
var x2js                     = new X2JS();

var LtiAppConfiguration = Ember.Model.extend({
  isDeserializing: false,

  // persisting attributes
  uid                        : attr(),     // string
  created_at                 : attr(Date), // datetime
  updated_at                 : attr(Date), // datetime
  config                     : attr(),     // json

  // non-persisting attributes
  originalConfig             : null,       // Used for backup via deserialize
  config_options             : [],
  custom_fields              : [],
  editor_button              : null,
  resource_selection         : null,
  homework_submission        : null,
  course_nav                 : null,
  account_nav                : null,
  user_nav                   : null,

  // Mappings
  title: function() { return this.get('config.title'); }.property('config.title'),
  titleObserver: function() { this.set('config.title', this.get('title')); }.observes('title'),
  description: function() { return this.get('config.description'); }.property('config.description'),
  descriptionObserver: function() { this.set('config.description', this.get('description')); }.observes('description'),
  icon_url: function() { return this.get('config.icon_url'); }.property('config.icon_url'),
  icon_urlObserver: function() { this.set('config.icon_url', this.get('icon_url')); }.observes('icon_url'),
  launch_url: function() { return this.get('config.launch_url'); }.property('config.launch_url'),
  launch_urlObserver: function() { this.set('config.launch_url', this.get('launch_url')); }.observes('launch_url'),
  short_name: function() { return this.get('canvas_extension.tool_id'); }.property('canvas_extension.tool_id'),
  short_nameObserver: function() { this.set('canvas_extension.tool_id', this.get('short_name')); }.observes('short_name'),
  default_link_text: function() { return this.get('canvas_extension.default_link_text'); }.property('canvas_extension.default_link_text'),
  default_link_textObserver: function() { this.set('canvas_extension.default_link_text', this.get('default_link_text')); }.observes('default_link_text'),
  default_selection_width: function() { return this.get('canvas_extension.default_selection_width'); }.property('canvas_extension.default_selection_width'),
  default_selection_widthObserver: function() { this.set('canvas_extension.default_selection_width', this.get('default_selection_width')); }.observes('default_selection_width'),
  default_selection_height: function() { return this.get('canvas_extension.default_selection_height'); }.property('canvas_extension.default_selection_height'),
  default_selection_heightObserver: function() { this.set('canvas_extension.default_selection_height', this.get('default_selection_height')); }.observes('default_selection_height'),
  privacy_level: function() { return this.get('canvas_extension.privacy_level'); }.property('canvas_extension.privacy_level'),
  privacy_levelObserver: function() { this.set('canvas_extension.privacy_level', this.get('privacy_level')); }.observes('privacy_level'),
  domain: function() { return this.get('canvas_extension.domain'); }.property('canvas_extension.domain'),
  domainObserver: function() { this.set('canvas_extension.domain', this.get('domain')); }.observes('domain'),

  // editor_button_enabled: function() { return this.get('editor_button.is_enabled') }.property('editor_button.is_enabled'),
  // resource_selection_enabled: function() { return this.get('resource_selection.is_enabled') }.property('resource_selection.is_enabled'),
  // homework_submission_enabled: function() { return this.get('homework_submission.is_enabled') }.property('homework_submission.is_enabled'),
  // course_nav_enabled: function() { return this.get('course_nav.is_enabled') }.property('course_nav.is_enabled'),
  // account_nav_enabled: function() { return this.get('account_nav.is_enabled') }.property('account_nav.is_enabled'),
  // user_nav_enabled: function() { return this.get('user_nav.is_enabled') }.property('user_nav.is_enabled'),

  xml: function() {
    return "Coming soon";
    // return Ember.$.get('/api/v1/json_to_xml', { data: this.get('config') }).then(function(results) {
    //   return results;
    // });
  }.property('title', 'description', 'icon_url', 'launch_url', 'short_name', 'default_link_text',
             'default_selection_width', 'default_selection_height', 'privacy_level', 'domain',
             'custom_fields.@each.modifiedAt', 'config_options.@each.modifiedAt', 
             'editor_button.modifiedAt', 'resource_selection.modifiedAt', 
             'homework_submission.modifiedAt', 'course_nav.modifiedAt', 'account_nav.modifiedAt', 
             'user_nav.modifiedAt'),

  custom_fieldsObserver: function() {
    if (this.get('isDeserializing') === false) {
      Ember.run.next(this, function() {
        var cfs = this.get('config.custom_fields');
        cfs.clear();
        Ember.$.each(this.get('custom_fields'), function(idx, cf) {
          cfs.addObject(cf.getJson());
        });
      });
    }
  }.observes('custom_fields.@each.modifiedAt'),

  config_optionsObserver: function() {
    if (this.get('isDeserializing') === false) {
      Ember.run.next(this, function() {
        var cos = this.get('config.config_options');
        cos.clear();
        Ember.$.each(this.get('config_options'), function(idx, co) {
          cos.addObject(co.getJson());
        });
      });
    }
  }.observes('config_options.@each.modifiedAt'),

  canvas_extension: function() {
    var exts = this.get('config.extensions');
    if (!Ember.isEmpty(exts)) {
      return exts.findProperty('platform', 'canvas.instructure.com')
    }
  }.property('config.extensions.[]'),

  deserialize: function() {
    console.log("DESERIALIZING");
    this.set('isDeserializing', true);
    this.set('originalConfig', this.get('config'));
    this.deserializeConfigOptions();
    this.deserializeCustomFields();
    this.deserializeExtensionOptions();
    this.set('isDeserializing', false);
  },

  deserializeConfigOptions: function() {
    this.set('config_options', []);
    var co = this.get('config_options');
    if (!Ember.isEmpty(this.get('config.config_options'))) {
      Ember.$.each(this.get('config.config_options'), function(idx, opt) {
        co.pushObject(ConfigOption.create({
          name          : opt.name,
          description   : opt.description,
          type          : opt.type,
          default_value : opt.default_value,
          is_required   : opt.is_required
        }));
      });
    }
  },

  deserializeCustomFields: function() {
    this.set('custom_fields', []);
    var cf = this.get('custom_fields');
    if (!Ember.isEmpty(this.get('config.custom_fields'))) {
      Ember.$.each(this.get('config.custom_fields'), function(idx, opt) {
        cf.pushObject(CustomField.create({
          name  : opt.name,
          value : opt.value
        }));
      });
    }
  },

  deserializeExtensionOptions: function() {
    _this = this;
    this.set('editor_button', CustomButtonSettings.create({ name: 'editor_button' }));
    this.set('resource_selection', CustomButtonSettings.create({ name: 'resource_selection' }));
    this.set('homework_submission', CustomButtonSettings.create({ name: 'homework_submission' }));
    this.set('course_nav', CustomNavigationSettings.create({ name: 'course_nav' }));
    this.set('account_nav', NavigationSettings.create({ name: 'account_nav' }));
    this.set('user_nav', NavigationSettings.create({ name: 'user_nav' }));

    var opts = this.get('canvas_extension.options');
    if (!Ember.isEmpty(opts)) {
      Ember.$.each(this.get('canvas_extension.options'), function(idx, opt) {
        var name = opt.name;
        var settings = _this.get(name);
        if (settings) {
          settings.set('is_enabled', true);
          Ember.$.each(opt, function(key, value) {
            settings.set(key, value);
          });
        }
        console.log(settings);
      });
    }
  },

  canvas_extensionsObserver: function() {
    if (this.get('isDeserializing') === false) {
      console.log("MODIFYING EXTENSIONS");
      var opts = this.get('canvas_extension.options');
      opts.clear();
      if (this.get('editor_button.is_enabled')) {
        opts.addObject(this.get('editor_button').getJson());
      }
      if (this.get('resource_selection.is_enabled')) {
        opts.addObject(this.get('resource_selection').getJson());
      }
      if (this.get('homework_submission.is_enabled')) {
        opts.addObject(this.get('homework_submission').getJson());
      }
      if (this.get('course_nav.is_enabled')) {
        opts.addObject(this.get('course_nav').getJson());
      }
      if (this.get('account_nav.is_enabled')) {
        opts.addObject(this.get('account_nav').getJson());
      }
      if (this.get('user_nav.is_enabled')) {
        opts.addObject(this.get('user_nav').getJson());
      }
    }
  }.observes('editor_button.modifiedAt', 'resource_selection.modifiedAt', 'homework_submission.modifiedAt',
             'course_nav.modifiedAt', 'account_nav.modifiedAt', 'user_nav.modifiedAt'),

}).reopenClass({
  rootKey       : 'lti_app_configuration',
  collectionKey : 'lti_app_configurations',
  url           : '/api/v1/lti_app_configurations',
  adapter       : Ember.RESTAdapter.create()
});

module.exports = LtiAppConfiguration;