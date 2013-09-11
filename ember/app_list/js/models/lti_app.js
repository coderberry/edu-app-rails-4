var attr = DS.attr;

var LtiApp = DS.Model.extend({
  short_name        : attr(),
  name              : attr(),
  short_description : attr(),
  status            : attr(),
  is_public         : attr({ type : Boolean }),
  app_type          : attr(),
  preview_url       : attr(),
  banner_image_url  : attr(),
  logo_image_url    : attr(),
  icon_image_url    : attr(),
  average_rating    : attr({ type : Number }),
  total_ratings     : attr({ type : Number }),

  showUrl: function() {
    return "/apps/" + this.get('short_name');
  }.property('short_name')
});

module.exports = LtiApp;

