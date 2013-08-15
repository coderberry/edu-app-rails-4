App.FormData = Ember.Object.extend({
  short_name: null,
  name: null,
  short_description: null,
  link_text: null,
  lti_launch_url: null,
  icon_image_url: null,
  selection_width: null,
  selection_height: null,
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
            },
            {
              _name: 'text',
              __prefix: 'lticm',
              __text: this.get('link_text')
            },
            {
              _name: 'selection_width',
              __prefix: 'lticm',
              __text: this.get('selection_width')
            },
            {
              _name: 'selection_height',
              __prefix: 'lticm',
              __text: this.get('selection_height')
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
      var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
      if (!Ember.isEmpty(this.get('editorButtonSettings.lti_launch_url'))) {
        props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('editorButtonSettings.lti_launch_url') });
      }
      if (!Ember.isEmpty(this.get('editorButtonSettings.icon_image_url'))) {
        props.push({ _name: 'icon_url', __prefix: 'lticm', __text: this.get('editorButtonSettings.icon_image_url') });
      }
      if (!Ember.isEmpty(this.get('editorButtonSettings.link_text'))) {
        props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('editorButtonSettings.link_text') });
      }
      if (!Ember.isEmpty(this.get('editorButtonSettings.selection_width'))) {
        props.push({ _name: 'selection_width', __prefix: 'lticm', __text: this.get('editorButtonSettings.selection_width') });
      }
      if (!Ember.isEmpty(this.get('editorButtonSettings.selection_height'))) {
        props.push({ _name: 'selection_height', __prefix: 'lticm', __text: this.get('editorButtonSettings.selection_height') });
      }
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: props,
        _name: 'editor_button',
        __prefix: 'lticm'
      });
    }

    if (this.get('useLinkSelection') === true) {
      var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
      if (!Ember.isEmpty(this.get('linkSelectionSettings.lti_launch_url'))) {
        props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('linkSelectionSettings.lti_launch_url') });
      }
      if (!Ember.isEmpty(this.get('linkSelectionSettings.icon_image_url'))) {
        props.push({ _name: 'icon_url', __prefix: 'lticm', __text: this.get('linkSelectionSettings.icon_image_url') });
      }
      if (!Ember.isEmpty(this.get('linkSelectionSettings.link_text'))) {
        props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('linkSelectionSettings.link_text') });
      }
      if (!Ember.isEmpty(this.get('linkSelectionSettings.selection_width'))) {
        props.push({ _name: 'selection_width', __prefix: 'lticm', __text: this.get('linkSelectionSettings.selection_width') });
      }
      if (!Ember.isEmpty(this.get('linkSelectionSettings.selection_height'))) {
        props.push({ _name: 'selection_height', __prefix: 'lticm', __text: this.get('linkSelectionSettings.selection_height') });
      }
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: props,
        _name: 'resource_selection',
        __prefix: 'lticm'
      });
    }

    if (this.get('useHomeworkSubmission') === true) {
      var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
      if (!Ember.isEmpty(this.get('homeworkSubmissionSettings.lti_launch_url'))) {
        props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.lti_launch_url') });
      }
      if (!Ember.isEmpty(this.get('homeworkSubmissionSettings.icon_image_url'))) {
        props.push({ _name: 'icon_url', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.icon_image_url') });
      }
      if (!Ember.isEmpty(this.get('homeworkSubmissionSettings.link_text'))) {
        props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.link_text') });
      }
      if (!Ember.isEmpty(this.get('homeworkSubmissionSettings.selection_width'))) {
        props.push({ _name: 'selection_width', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.selection_width') });
      }
      if (!Ember.isEmpty(this.get('homeworkSubmissionSettings.selection_height'))) {
        props.push({ _name: 'selection_height', __prefix: 'lticm', __text: this.get('homeworkSubmissionSettings.selection_height') });
      }
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: props,
        _name: 'homework_submission',
        __prefix: 'lticm'
      });
    }

    if (this.get('useCourseNavigation') === true) {
      var props = [
        { _name: 'enabled', __prefix: 'lticm', __text: 'true' },
        { _name: 'visibility', __prefix: 'lticm', __text: this.get('courseNavigationSettings.visibility') },
        { _name: 'default', __prefix: 'lticm', __text: this.get('courseNavigationSettings.enabledByDefault') === true ? 'enabled' : 'disabled' }
      ];
      if (!Ember.isEmpty(this.get('courseNavigationSettings.lti_launch_url'))) {
        props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('courseNavigationSettings.lti_launch_url') });
      }
      if (!Ember.isEmpty(this.get('courseNavigationSettings.link_text'))) {
        props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('courseNavigationSettings.link_text') });
      }
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: props,
        _name: 'course_navigation',
        __prefix: 'lticm'
      });
    }

    if (this.get('useAccountNavigation') === true) {
      var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
      if (!Ember.isEmpty(this.get('accountNavigationSettings.lti_launch_url'))) {
        props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('accountNavigationSettings.lti_launch_url') });
      }
      if (!Ember.isEmpty(this.get('accountNavigationSettings.link_text'))) {
        props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('accountNavigationSettings.link_text') });
      }
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: props,
        _name: 'account_navigation',
        __prefix: 'lticm'
      });
    }

    if (this.get('useUserNavigation') === true) {
      var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
      if (!Ember.isEmpty(this.get('userNavigationSettings.lti_launch_url'))) {
        props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('userNavigationSettings.lti_launch_url') });
      }
      if (!Ember.isEmpty(this.get('userNavigationSettings.link_text'))) {
        props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('userNavigationSettings.link_text') });
      }
      cartridge.cartridge_basiclti_link.extensions.options.push({
        property: props,
        _name: 'user_navigation',
        __prefix: 'lticm'
      });
    }

    var xml = x2js.json2xml_str(cartridge);
    return vkbeautify.xml(xml.toString());
  }.property(
    'short_name', 'name', 'link_text', 'short_description', 'lti_launch_url', 'icon_image_url', 'launch_privacy', 'domain', 'custom_fields.@each.name', 'custom_fields.@each.value', 
    'useEditorButton', 'editorButtonSettings.modifiedAt', 'useLinkSelection', 'linkSelectionSettings.modifiedAt', 'selection_width', 'selection_height',
    'useHomeworkSubmission', 'homeworkSubmissionSettings.modifiedAt', 'useCourseNavigation', 'courseNavigationSettings.modifiedAt',
    'useAccountNavigation', 'accountNavigationSettings.modifiedAt', 'useUserNavigation', 'userNavigationSettings.modifiedAt'
  )
});