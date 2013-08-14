//= require vkbeautify.0.99.00.beta
//= require xml2json
//= require handlebars-1.0.0
//= require ember-1.0.0-rc.7.js
//= require_self

var App = window.App = Ember.Application.create({
  rootElement: '#ember-app'
});

App.launchPrivacy = [
  Ember.Object.create({name: "Anonymous", value: "anonymous"}),
  Ember.Object.create({name: "Name Only", value: "name_only"}),
  Ember.Object.create({name: "Public", value: "public"})
]

App.visibilityOptions = [
  Ember.Object.create({name: "Public", value: "public"}),
  Ember.Object.create({name: "Members Only", value: "members"}),
  Ember.Object.create({name: "Admins Only", value: "admins"})
]

App.CustomField = Ember.Object.extend({ name: '', value: '' });

App.CustomButtonSettings = Ember.Object.extend({
  lti_launch_url: null,
  link_text: null,
  icon_image_url: null,
  selection_width: null,
  selection_height: null,

  modifiedAt: function() {
    return new Date();
  }.property('lti_launch_url', 'link_text', 'icon_image_url', 'selection_width', 'selection_height')
});

App.CourseNavigationSettings = Ember.Object.extend({
  lti_launch_url: null,
  link_text: null,
  visibility: 'public',
  enabledByDefault: true,

  modifiedAt: function() {
    return new Date();
  }.property('lti_launch_url', 'link_text', 'visibility', 'enabledByDefault')
});

App.NavigationSettings = Ember.Object.extend({
  lti_launch_url: null,
  link_text: null,

  modifiedAt: function() {
    return new Date();
  }.property('lti_launch_url', 'link_text')
});

App.FormData = Ember.Object.extend({
  short_name: null,
  name: null,
  short_description: null,
  link_text: null,
  lti_launch_url: null,
  icon_image_url: null,
  launch_privacy: null,
  domain: null,
  custom_fields: [],
  useEditorButton: false,
  editorButtonSettings: null,
  useLinkSelection: false,
  linkSelectionSettings: null,
  useHomeworkSubmission: false,
  homeworkSubmissionSettings: null,
  useCourseNavigation: false,
  courseNavigationSettings: null,
  useAccountNavigation: false,
  accountNavigationSettings: null,
  useUserNavigation: false,
  userNavigationSettings: null,

  xml: function() {
    var x2js = new X2JS();

    var cartridge = { 
      cartridge_basiclti_link: {
        title: {
          __prefix: 'blti',
          __text: this.get('name')
        },
        description: {
          __prefix: 'blti',
          __text: this.get('short_description')
        },
        icon: {
          __prefix: 'blti',
          __text: this.get('icon_image_url')
        },
        launch_url: {
          __prefix: 'blti',
          __text: this.get('lti_launch_url')
        },
        custom: {
          property: [],
          __prefix: 'blti'
        },
        extensions: {
          property: [
            {
              _name: 'tool_id',
              __prefix: 'lticm',
              __text: this.get('short_name')
            },
            {
              _name: 'privacy_level',
              __prefix: 'lticm',
              __text: this.get('launch_privacy')
            },
            {
              _name: 'domain',
              __prefix: 'lticm',
              __text: this.get('domain')
            }
          ],
          options: [],
          _platform: 'canvas.instructure.com',
          __prefix: 'blti'
        },
        cartridge_bundle: {
          _identifierref: 'BLTI001_Bundle'
        },
        cartridge_icon: {
          _identifierref: 'BLTI001_Icon'
        },
        '_xmlns': 'http://www.imsglobal.org/xsd/imslticc_v1p0',
        '_xmlns:blti': 'http://www.imsglobal.org/xsd/imsbasiclti_v1p0',
        '_xmlns:lticm': 'http://www.imsglobal.org/xsd/imslticm_v1p0',
        '_xmlns:lticp': 'http://www.imsglobal.org/xsd/imslticp_v1p0',
        '_xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
        '_xsi:schemaLocation': 'http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd'
      }
    }

    this.get('custom_fields').forEach(function(cf) {
      if (!Ember.isEmpty(cf.get('name'))) {
        cartridge.cartridge_basiclti_link.custom.property.push({
          _name: cf.get('name'),
          __prefix: 'lticm',
          __text: cf.get('value')
        });
      }
    });

    if (this.get('useEditorButton') === true) {
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: [
          { _name: 'url', __prefix: 'lticm', __text: this.get('editorButtonSettings.lti_launch_url') },
          { _name: 'icon_url', __prefix: 'lticm', __text: this.get('editorButtonSettings.icon_image_url') },
          { _name: 'text', __prefix: 'lticm', __text: this.get('editorButtonSettings.link_text') },
          { _name: 'selection_width', __prefix: 'lticm', __text: this.get('editorButtonSettings.selection_width') },
          { _name: 'selection_height', __prefix: 'lticm', __text: this.get('editorButtonSettings.selection_height') },
          { _name: 'enabled', __prefix: 'lticm', __text: 'true' }
        ],
        _name: 'editor_button',
        __prefix: 'lticm'
      });
    }

    if (this.get('useLinkSelection') === true) {
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: [
          { _name: 'url', __prefix: 'lticm', __text: this.get('linkSelectionSettings.lti_launch_url') },
          { _name: 'icon_url', __prefix: 'lticm', __text: this.get('linkSelectionSettings.icon_image_url') },
          { _name: 'text', __prefix: 'lticm', __text: this.get('linkSelectionSettings.link_text') },
          { _name: 'selection_width', __prefix: 'lticm', __text: this.get('linkSelectionSettings.selection_width') },
          { _name: 'selection_height', __prefix: 'lticm', __text: this.get('linkSelectionSettings.selection_height') },
          { _name: 'enabled', __prefix: 'lticm', __text: 'true' }
        ],
        _name: 'resource_selection',
        __prefix: 'lticm'
      });
    }

    if (this.get('useHomeworkSubmission') === true) {
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: [
          { _name: 'url', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.lti_launch_url') },
          { _name: 'icon_url', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.icon_image_url') },
          { _name: 'text', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.link_text') },
          { _name: 'selection_width', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.selection_width') },
          { _name: 'selection_height', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.selection_height') },
          { _name: 'enabled', __prefix: 'lticm', __text: 'true' }
        ],
        _name: 'homework_submission',
        __prefix: 'lticm'
      });
    }

    if (this.get('useCourseNavigation') === true) {
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: [
          { _name: 'url', __prefix: 'lticm', __text: this.get('courseNavigationSettings.lti_launch_url') },
          { _name: 'text', __prefix: 'lticm', __text: this.get('courseNavigationSettings.link_text') },
          { _name: 'visibility', __prefix: 'lticm', __text: this.get('courseNavigationSettings.visibility') },
          { _name: 'default', __prefix: 'lticm', __text: this.get('courseNavigationSettings.enabledByDefault') === true ? 'enabled' : 'disabled' },
          { _name: 'enabled', __prefix: 'lticm', __text: 'true' }
        ],
        _name: 'course_navigation',
        __prefix: 'lticm'
      });
    }
    
    if (this.get('useAccountNavigation') === true) {
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: [
          { _name: 'url', __prefix: 'lticm', __text: this.get('accountNavigationSettings.lti_launch_url') },
          { _name: 'text', __prefix: 'lticm', __text: this.get('accountNavigationSettings.link_text') },
          { _name: 'enabled', __prefix: 'lticm', __text: 'true' }
        ],
        _name: 'account_navigation',
        __prefix: 'lticm'
      });
    }

    if (this.get('useUserNavigation') === true) {
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: [
          { _name: 'url', __prefix: 'lticm', __text: this.get('userNavigationSettings.lti_launch_url') },
          { _name: 'text', __prefix: 'lticm', __text: this.get('userNavigationSettings.link_text') },
          { _name: 'enabled', __prefix: 'lticm', __text: 'true' }
        ],
        _name: 'user_navigation',
        __prefix: 'lticm'
      });
    }

    var xml = x2js.json2xml_str(cartridge);
    return vkbeautify.xml(xml.toString());
  }.property(
    'short_name', 'name', 'link_text', 'short_description', 'lti_launch_url', 'icon_image_url', 'launch_privacy', 'domain', 'custom_fields.@each.name', 'custom_fields.@each.value', 
    'useEditorButton', 'editorButtonSettings.modifiedAt', 'useLinkSelection', 'linkSelectionSettings.modifiedAt',
    'useHomeworkSubmission', 'homeworkSubmissionSettings.modifiedAt', 'useCourseNavigation', 'courseNavigationSettings.modifiedAt',
    'useAccountNavigation', 'accountNavigationSettings.modifiedAt', 'useUserNavigation', 'userNavigationSettings.modifiedAt'
  )
});

App.ApplicationController = Ember.ObjectController.extend({
  buildXml: function() {
    Ember.debug("Building...");
  },

  addCustomField: function() {
    customField = App.CustomField.create();
    this.get('model').get('custom_fields').pushObject(customField);
  },

  removeCustomField: function(cf) {
    this.get('model').get('custom_fields').removeObject(cf);
  },

  showEditorButtonSettings: function() {
    return this.get('model.useEditorButton');
  }.observes('useEditorButton')
});

App.XmlController = Ember.ObjectController.extend({
});

App.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return App.FormData.create({
      launch_privacy: 'public',
      editorButtonSettings: App.CustomButtonSettings.create(),
      linkSelectionSettings: App.CustomButtonSettings.create(),
      homeworkSubmissionSettings: App.CustomButtonSettings.create(),
      courseNavigationSettings: App.CourseNavigationSettings.create(),
      accountNavigationSettings: App.CourseNavigationSettings.create(),
      userNavigationSettings: App.CourseNavigationSettings.create()
    });
  }
})