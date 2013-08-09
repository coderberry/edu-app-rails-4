var LtiApp = DS.Model.extend({
  user_id:           DS.attr('string'),
  short_name:        DS.attr('string'),
  name:              DS.attr('string'),
  short_description: DS.attr('string'),
  description:       DS.attr('string'),
  status:            DS.attr('string'),
  support_url:       DS.attr('string'),
  author_name:       DS.attr('string'),
  is_public:         DS.attr('boolean'),
  app_type:          DS.attr('string'),
  ims_cert_url:      DS.attr('string'),
  preview_url:       DS.attr('string'),
  config_url:        DS.attr('string'),
  data_url:          DS.attr('string'),
  banner_image_url:  DS.attr('string'),
  logo_image_url:    DS.attr('string'),
  icon_image_url:    DS.attr('string')
});

module.exports = LtiApp;

