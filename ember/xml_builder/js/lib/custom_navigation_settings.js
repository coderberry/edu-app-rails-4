var Jsonable = require('../mixins/jsonable');

var CourseNavigationSettings = Ember.Object.extend(Jsonable, {
  modified_at   : new Date(),
  enabled       : false,
  is_optional   : false,
  name          : null,
  url           : null,
  link_text     : null,
  visibility    : 'public',
  default       : null,

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes('enabled', 'is_optional', 'name', 'url', 'link_text', 'visibility', 'default'),

  getJson: function() {
    return {
      enabled     : this.get('enabled'),
      is_optional : this.get('is_optional'),
      url         : this.get('url'),
      text        : this.get('link_text'),
      visibility  : this.get('visibility'),
      default     : (this.get('default') == true ? 'disabled' : null )
    }
  },

  processDefault: function() {
    if(this.get('default') == 'disabled'){
      this.set('default', true)
    }
  }.observes('default')

});

module.exports = CourseNavigationSettings;
