var moment = require('../vendor/moment.min');

Ember.Handlebars.helper('fromNow', function(d) {
  return moment(d).fromNow();
});

