// require other, dependencies here, ie:
require('../vendor/xml2json');

// require('../vendor/jquery'); <-- This is being included via Rails
require('../vendor/handlebars');
require('../vendor/ember');
require('../vendor/ember-model-latest');

var App = window.App = Ember.Application.create({
  rootElement: '#ember-app',
  LOG_TRANSITIONS: true,
  launchPrivacy: [
    Ember.Object.create({name: "Anonymous", value: "anonymous"}),
    Ember.Object.create({name: "Name Only", value: "name_only"}),
    Ember.Object.create({name: "Public", value: "public"})
  ],
  visibilityOptions: [
    Ember.Object.create({name: "Public", value: "public"}),
    Ember.Object.create({name: "Members Only", value: "members"}),
    Ember.Object.create({name: "Admins Only", value: "admins"})
  ],
  fieldTypes: [
    Ember.Object.create({name: "Text", value: "text"}),
    Ember.Object.create({name: "Checkbox", value: "checkbox"})
  ]
});

require('../lib/flash');

module.exports = App;

