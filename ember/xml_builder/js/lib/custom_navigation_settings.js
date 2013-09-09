var Jsonable = require('../mixins/jsonable');

var CourseNavigationSettings = Ember.Object.extend(Jsonable, {
  modified_at        : new Date(),
  is_enabled         : false,
  is_optional        : false,
  name               : null,
  launch_url         : null,
  link_text          : null,
  visibility         : 'public',
  enabled_by_default : true,

  changeObserver: function() {
    this.set('modified_at', new Date());
  }.observes('is_enabled', 'is_optional', 'name', 'launch_url', 'link_text', 'visibility', 'enabled_by_default'),

  getJson: function() {
    return {
      is_enabled         : this.get('is_enabled'),
      is_optional        : this.get('is_optional'),
      name               : this.get('name'),
      launch_url         : this.get('launch_url'),
      link_text          : this.get('link_text'),
      visibility         : this.get('visibility'),
      enabled_by_default : this.get('enabled_by_default')
    }
  }
});

module.exports = CourseNavigationSettings;
