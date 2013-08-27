// var attr                     = Ember.attr;
// var App                      = require('../config/app');
// var CustomField              = require('../lib/custom_field');
// var CustomButtonSettings     = require('../lib/custom_button_settings');
// var CustomNavigationSettings = require('../lib/custom_navigation_settings');
// var NavigationSettings       = require('../lib/navigation_settings');
// var X2JS                     = require('../vendor/xml2json');
// var x2js                     = new X2JS();

// var Cartridge = Ember.Model.extend({

//   // persisting attributes
//   uid                        : attr(),     // string
//   name                       : attr(),     // string
//   xml                        : attr(),     // string
//   created_at                 : attr(Date), // datetime
//   updated_at                 : attr(Date), // datetime

//   // supplementary attributes
//   raw_json                   : {},
//   errors                     : {},
//   short_name                 : null,
//   short_description          : null,
//   link_text                  : null,
//   lti_launch_url             : null,
//   icon_image_url             : null,
//   selection_width            : null,
//   selection_height           : null,
//   launch_privacy             : null,
//   domain                     : null,
//   custom_fields              : [],
//   useEditorButton            : false,
//   editorButtonSettings       : null,
//   useLinkSelection           : false,
//   linkSelectionSettings      : null,
//   useHomeworkSubmission      : false,
//   homeworkSubmissionSettings : null,
//   useCourseNavigation        : false,
//   courseNavigationSettings   : null,
//   useAccountNavigation       : false,
//   accountNavigationSettings  : null,
//   useUserNavigation          : false,
//   userNavigationSettings     : null,

//   isDeserializing: false,

//   // update the cartridge with the stringified JSON then save
//   persist: function() {
//     var _this = this;
//     var url = '/api/v1/cartridges';
//     if (!Ember.isEmpty(this.get('uid'))) {
//       url = '/api/v1/cartridges/' + this.get('uid');
//     }
//     data = {
//       name: this.get('name'),
//       xml: this.get('xml')
//     };
//     Ember.$.post(url, data)
//     .done(function(data) {
//       if (data['cartridge']) {
//         _this.set('uid',        data['cartridge']['uid']);
//         _this.set('name',       data['cartridge']['name']);
//         _this.set('created_at', data['cartridge']['created_at']);
//         _this.set('updated_at', data['cartridge']['updated_at']);
//         _this.trigger('didSaveRecord');
//       }
//       App.FlashQueue.pushFlash('notice', 'Your cartridge has been saved!');
//     }, 'json')
//     .fail(function(err) {
//       App.FlashQueue.pushFlash('error', 'Please correct the fields below');
//       _this.set('errors', err.responseJSON['errors']);
//     });
//   },

//   deserialize: function() {
//     if (this.get('isLoaded') === true) {
//       _this = this;
//       this.set('isDeserializing', true);
//       var json_xml = Em.Object.create(x2js.xml_str2json(this.get('xml')));

//       this.set('name',                  json_xml.get('cartridge_basiclti_link.title.__text'));
//       this.set('short_description',     json_xml.get('cartridge_basiclti_link.description.__text'));
//       this.set('lti_launch_url',        json_xml.get('cartridge_basiclti_link.launch_url.__text'));
//       this.set('icon_image_url',        json_xml.get('cartridge_basiclti_link.icon.__text'));

//       var props = json_xml.get('cartridge_basiclti_link.extensions.property');
//       Ember.$.each(props, function(idx, prop) {
//         if (prop._name === 'tool_id') {
//           _this.set('short_name', prop.__text);
//         }
//         else if (prop._name === 'text') {
//           _this.set('link_text', prop.__text);
//         }
//         else if (prop._name === 'selection_width') {
//           _this.set('selection_width', prop.__text);
//         }
//         else if (prop._name === 'selection_height') {
//           _this.set('selection_height', prop.__text);
//         }
//         else if (prop._name === 'privacy_level') {
//           _this.set('launch_privacy', prop.__text);
//         }
//         else if (prop._name === 'domain') {
//           _this.set('domain', prop.__text);
//         }
//         else {
//           Ember.debug("UNKNOWN: " + prop._name);
//         }
//       });

//       this.set('custom_fields', []);
//       var customProps = json_xml.get('cartridge_basiclti_link.custom.property');
//       if (customProps) {
//         if (!Ember.isArray(customProps)) {
//           customProps = [customProps];
//         }
//         Ember.$.each(customProps, function(idx, prop) {
//           if (!_this.get('custom_fields').mapProperty('name').contains(prop._name)) {
//             _this.get('custom_fields').pushObject(CustomField.create({ 
//               name: prop._name, 
//               value: prop.__text,
//               description: prop._description,
//               type: prop._type,
//               required: (prop._required === 'true')
//             }));
//           }
//         });
//       }

//       var exts = json_xml.get('cartridge_basiclti_link.extensions.options');
//       if (exts) {
//         Ember.$.each(exts, function(idx, ext) {
//           if (ext._name === 'editor_button') {
//             _this.set('useEditorButton', true);
//             var container = _this.get('editorButton');
//             container.set('is_optional', (ext._optional === 'true'));
//             Ember.$.each(ext.property, function(ldx, prop) {
//               if (prop._name === 'url') { container.set('lti_launch_url', prop.__text); }
//               if (prop._name === 'text') { container.set('link_text', prop.__text); }
//               if (prop._name === 'icon_url') { container.set('icon_image_url', prop.__text); }
//               if (prop._name === 'selection_width') { container.set('selection_width', prop.__text); }
//               if (prop._name === 'selection_height') { container.set('selection_height', prop.__text); }
//             });
//           }
//           else if (ext._name === 'resource_selection') {
//             _this.set('useLinkSelection', true);
//             var container = _this.get('linkSelection');
//             container.set('is_optional', (ext._optional === 'true'));
//             Ember.$.each(ext.property, function(ldx, prop) {
//               if (prop._name === 'url') { container.set('lti_launch_url', prop.__text); }
//               if (prop._name === 'text') { container.set('link_text', prop.__text); }
//               if (prop._name === 'icon_url') { container.set('icon_image_url', prop.__text); }
//               if (prop._name === 'selection_width') { container.set('selection_width', prop.__text); }
//               if (prop._name === 'selection_height') { container.set('selection_height', prop.__text); }
//             });
//           }
//           else if (ext._name === 'homework_submission') {
//             _this.set('useHomeworkSubmission', true);
//             var container = _this.get('homeworkSubmission');
//             container.set('is_optional', (ext._optional === 'true'));
//             Ember.$.each(ext.property, function(ldx, prop) {
//               if (prop._name === 'url') { container.set('lti_launch_url', prop.__text); }
//               if (prop._name === 'text') { container.set('link_text', prop.__text); }
//               if (prop._name === 'icon_url') { container.set('icon_image_url', prop.__text); }
//               if (prop._name === 'selection_width') { container.set('selection_width', prop.__text); }
//               if (prop._name === 'selection_height') { container.set('selection_height', prop.__text); }
//             });
//           }
//           else if (ext._name === 'course_navigation') {
//             _this.set('useCourseNavigation', true);
//             var container = _this.get('courseNavigation');
//             container.set('is_optional', (ext._optional === 'true'));
//             Ember.$.each(ext.property, function(ldx, prop) {
//               if (prop._name === 'url') { container.set('lti_launch_url', prop.__text); }
//               if (prop._name === 'text') { container.set('link_text', prop.__text); }
//               if (prop._name === 'enabled') { container.set('enabled', prop.__text); }
//               if (prop._name === 'visibility') { container.set('visibility', prop.__text); }
//               if (prop._name === 'default') { container.set('default', prop.__text); }
//             });
//           }
//           else if (ext._name === 'account_navigation') {
//             _this.set('useAccountNavigation', true);
//             var container = _this.get('accountNavigation');
//             container.set('is_optional', (ext._optional === 'true'));
//             Ember.$.each(ext.property, function(ldx, prop) {
//               if (prop._name === 'url') { container.set('lti_launch_url', prop.__text); }
//               if (prop._name === 'text') { container.set('link_text', prop.__text); }
//             });
//           }
//           else if (ext._name === 'user_navigation') {
//             _this.set('useUserNavigation', true);
//             var container = _this.get('userNavigation');
//             container.set('is_optional', (ext._optional === 'true'));
//             Ember.$.each(ext.property, function(ldx, prop) {
//               if (prop._name === 'url') { container.set('lti_launch_url', prop.__text); }
//               if (prop._name === 'text') { container.set('link_text', prop.__text); }
//             });
//           }
//         });
//       }

//       this.set('isDeserializing', false);
//       this.updateCartridge();
//     }
//   }.observes('isLoaded'),

//   // property which populates the attribute if it isn't set already
//   editorButton: function() {
//     if (Ember.isEmpty(this.get('editorButtonSettings'))) {
//       this.set('editorButtonSettings', CustomButtonSettings.create());
//     }
//     return this.get('editorButtonSettings');
//   }.property('editorButtonSettings'),

//   // property which populates the attribute if it isn't set already
//   linkSelection: function() {
//     if (Ember.isEmpty(this.get('linkSelectionSettings'))) {
//       this.set('linkSelectionSettings', CustomButtonSettings.create());
//     }
//     return this.get('linkSelectionSettings');
//   }.property('linkSelectionSettings'),

//   // property which populates the attribute if it isn't set already
//   homeworkSubmission: function() {
//     if (Ember.isEmpty(this.get('homeworkSubmissionSettings'))) {
//       this.set('homeworkSubmissionSettings', CustomButtonSettings.create());
//     }
//     return this.get('homeworkSubmissionSettings');
//   }.property('homeworkSubmissionSettings'),

//   // property which populates the attribute if it isn't set already
//   courseNavigation: function() {
//     if (Ember.isEmpty(this.get('courseNavigationSettings'))) {
//       this.set('courseNavigationSettings', CustomNavigationSettings.create());
//     }
//     return this.get('courseNavigationSettings');
//   }.property('courseNavigationSettings'),

//   // property which populates the attribute if it isn't set already
//   accountNavigation: function() {
//     if (Ember.isEmpty(this.get('accountNavigationSettings'))) {
//       this.set('accountNavigationSettings', NavigationSettings.create());
//     }
//     return this.get('accountNavigationSettings');
//   }.property('accountNavigationSettings'),

//   // property which populates the attribute if it isn't set already
//   userNavigation: function() {
//     if (Ember.isEmpty(this.get('userNavigationSettings'))) {
//       this.set('userNavigationSettings', NavigationSettings.create());
//     }
//     return this.get('userNavigationSettings');
//   }.property('userNavigationSettings'),

//   rawJsonChanged: function() {
//     if ((this.get('isDeserializing') !== true) && (this.get('isLoaded') === true)) {
//       this.set('xml', x2js.json2xml_str(this.get('raw_json')));
//     }
//   }.observes('raw_json'),

//   // Creates a JSON representation which can be translated to XML and stores the
//   // results (JSON) into the `cartridge` attribute
//   updateCartridge: function() {
//     var json = { 
//       cartridge_basiclti_link: {
//         title: {
//           __prefix: 'blti',
//           __text: this.get('name')
//         },
//         description: {
//           __prefix: 'blti',
//           __text: this.get('short_description')
//         },
//         icon: {
//           __prefix: 'blti',
//           __text: this.get('icon_image_url')
//         },
//         launch_url: {
//           __prefix: 'blti',
//           __text: this.get('lti_launch_url')
//         },
//         custom: {
//           property: [],
//           __prefix: 'blti'
//         },
//         extensions: {
//           property: [
//             {
//               _name: 'tool_id',
//               __prefix: 'lticm',
//               __text: this.get('short_name')
//             },
//             {
//               _name: 'privacy_level',
//               __prefix: 'lticm',
//               __text: this.get('launch_privacy')
//             },
//             {
//               _name: 'domain',
//               __prefix: 'lticm',
//               __text: this.get('domain')
//             },
//             {
//               _name: 'text',
//               __prefix: 'lticm',
//               __text: this.get('link_text')
//             },
//             {
//               _name: 'selection_width',
//               __prefix: 'lticm',
//               __text: this.get('selection_width')
//             },
//             {
//               _name: 'selection_height',
//               __prefix: 'lticm',
//               __text: this.get('selection_height')
//             }
//           ],
//           options: [],
//           _platform: 'canvas.instructure.com',
//           __prefix: 'blti'
//         },
//         cartridge_bundle: {
//           _identifierref: 'BLTI001_Bundle'
//         },
//         cartridge_icon: {
//           _identifierref: 'BLTI001_Icon'
//         },
//         '_xmlns': 'http://www.imsglobal.org/xsd/imslticc_v1p0',
//         '_xmlns:blti': 'http://www.imsglobal.org/xsd/imsbasiclti_v1p0',
//         '_xmlns:lticm': 'http://www.imsglobal.org/xsd/imslticm_v1p0',
//         '_xmlns:lticp': 'http://www.imsglobal.org/xsd/imslticp_v1p0',
//         '_xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
//         '_xsi:schemaLocation': 'http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd'
//       }
//     }

//     this.get('custom_fields').forEach(function(cf) {
//       if (!Ember.isEmpty(cf.get('name'))) {
//         json.cartridge_basiclti_link.custom.property.push({
//           _name: cf.get('name'),
//           _description: cf.get('description'),
//           _type: cf.get('type'),
//           _required: cf.get('required'),
//           __prefix: 'lticm',
//           __text: cf.get('value')
//         });
//       }
//     });

//     if (this.get('useEditorButton') === true) {
//       var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
//       if (!Ember.isEmpty(this.get('editorButton.lti_launch_url'))) {
//         props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('editorButton.lti_launch_url') });
//       }
//       if (!Ember.isEmpty(this.get('editorButton.icon_image_url'))) {
//         props.push({ _name: 'icon_url', __prefix: 'lticm', __text: this.get('editorButton.icon_image_url') });
//       }
//       if (!Ember.isEmpty(this.get('editorButton.link_text'))) {
//         props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('editorButton.link_text') });
//       }
//       if (!Ember.isEmpty(this.get('editorButton.selection_width'))) {
//         props.push({ _name: 'selection_width', __prefix: 'lticm', __text: this.get('editorButton.selection_width') });
//       }
//       if (!Ember.isEmpty(this.get('editorButton.selection_height'))) {
//         props.push({ _name: 'selection_height', __prefix: 'lticm', __text: this.get('editorButton.selection_height') });
//       }
//       json.cartridge_basiclti_link.extensions.options.push({
//         property: props,
//         _name: 'editor_button',
//         _optional: this.get('editorButton.is_optional'),
//         __prefix: 'lticm'
//       });
//     }

//     if (this.get('useLinkSelection') === true) {
//       var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
//       if (!Ember.isEmpty(this.get('linkSelection.lti_launch_url'))) {
//         props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('linkSelection.lti_launch_url') });
//       }
//       if (!Ember.isEmpty(this.get('linkSelection.icon_image_url'))) {
//         props.push({ _name: 'icon_url', __prefix: 'lticm', __text: this.get('linkSelection.icon_image_url') });
//       }
//       if (!Ember.isEmpty(this.get('linkSelection.link_text'))) {
//         props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('linkSelection.link_text') });
//       }
//       if (!Ember.isEmpty(this.get('linkSelection.selection_width'))) {
//         props.push({ _name: 'selection_width', __prefix: 'lticm', __text: this.get('linkSelection.selection_width') });
//       }
//       if (!Ember.isEmpty(this.get('linkSelection.selection_height'))) {
//         props.push({ _name: 'selection_height', __prefix: 'lticm', __text: this.get('linkSelection.selection_height') });
//       }
//       json.cartridge_basiclti_link.extensions.options.push({
//         property: props,
//         _name: 'resource_selection',
//         _optional: this.get('linkSelection.is_optional'),
//         __prefix: 'lticm'
//       });
//     }

//     if (this.get('useHomeworkSubmission') === true) {
//       var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
//       if (!Ember.isEmpty(this.get('homeworkSubmission.lti_launch_url'))) {
//         props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('homeworkSubmission.lti_launch_url') });
//       }
//       if (!Ember.isEmpty(this.get('homeworkSubmission.icon_image_url'))) {
//         props.push({ _name: 'icon_url', __prefix: 'lticm', __text: this.get('homeworkSubmission.icon_image_url') });
//       }
//       if (!Ember.isEmpty(this.get('homeworkSubmission.link_text'))) {
//         props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('homeworkSubmission.link_text') });
//       }
//       if (!Ember.isEmpty(this.get('homeworkSubmission.selection_width'))) {
//         props.push({ _name: 'selection_width', __prefix: 'lticm', __text: this.get('homeworkSubmission.selection_width') });
//       }
//       if (!Ember.isEmpty(this.get('homeworkSubmission.selection_height'))) {
//         props.push({ _name: 'selection_height', __prefix: 'lticm', __text: this.get('homeworkSubmission.selection_height') });
//       }
//       json.cartridge_basiclti_link.extensions.options.push({
//         property: props,
//         _name: 'homework_submission',
//         _optional: this.get('homeworkSubmission.is_optional'),
//         __prefix: 'lticm'
//       });
//     }

//     if (this.get('useCourseNavigation') === true) {
//       var props = [
//         { _name: 'enabled', __prefix: 'lticm', __text: 'true' },
//         { _name: 'visibility', __prefix: 'lticm', __text: this.get('courseNavigation.visibility') },
//         { _name: 'default', __prefix: 'lticm', __text: this.get('courseNavigation.enabledByDefault') === true ? 'enabled' : 'disabled' }
//       ];
//       if (!Ember.isEmpty(this.get('courseNavigation.lti_launch_url'))) {
//         props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('courseNavigation.lti_launch_url') });
//       }
//       if (!Ember.isEmpty(this.get('courseNavigation.link_text'))) {
//         props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('courseNavigation.link_text') });
//       }
//       json.cartridge_basiclti_link.extensions.options.push({
//         property: props,
//         _name: 'course_navigation',
//         _optional: this.get('courseNavigation.is_optional'),
//         __prefix: 'lticm'
//       });
//     }

//     if (this.get('useAccountNavigation') === true) {
//       var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
//       if (!Ember.isEmpty(this.get('accountNavigation.lti_launch_url'))) {
//         props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('accountNavigation.lti_launch_url') });
//       }
//       if (!Ember.isEmpty(this.get('accountNavigation.link_text'))) {
//         props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('accountNavigation.link_text') });
//       }
//       json.cartridge_basiclti_link.extensions.options.push({
//         property: props,
//         _name: 'account_navigation',
//         _optional: this.get('accountNavigation.is_optional'),
//         __prefix: 'lticm'
//       });
//     }

//     if (this.get('useUserNavigation') === true) {
//       var props = [{ _name: 'enabled', __prefix: 'lticm', __text: 'true' }];
//       if (!Ember.isEmpty(this.get('userNavigation.lti_launch_url'))) {
//         props.push({  _name: 'url', __prefix: 'lticm', __text: this.get('userNavigation.lti_launch_url') });
//       }
//       if (!Ember.isEmpty(this.get('userNavigation.link_text'))) {
//         props.push({ _name: 'text', __prefix: 'lticm', __text: this.get('userNavigation.link_text') });
//       }
//       json.cartridge_basiclti_link.extensions.options.push({
//         property: props,
//         _name: 'user_navigation',
//         _optional: this.get('userNavigation.is_optional'),
//         __prefix: 'lticm'
//       });
//     }
//     this.set('raw_json', json);

//   }.observes(
//     'short_name', 'name', 'link_text', 'short_description', 'lti_launch_url', 'icon_image_url', 'launch_privacy', 'domain', 'custom_fields.@each.modifiedAt',
//     'useEditorButton', 'editorButton.modifiedAt', 'useLinkSelection', 'linkSelection.modifiedAt', 'selection_width', 'selection_height',
//     'useHomeworkSubmission', 'homeworkSubmission.modifiedAt', 'useCourseNavigation', 'courseNavigation.modifiedAt',
//     'useAccountNavigation', 'accountNavigation.modifiedAt', 'useUserNavigation', 'userNavigation.modifiedAt'
//   )

// // Configure Ember Model
// }).reopenClass({
//   rootKey       : 'cartridge',
//   collectionKey : 'cartridges',
//   url           : '/api/v1/cartridges',
//   adapter       : Ember.RESTAdapter.create()
// });

// module.exports = Cartridge;

