//{{lti-xml config=model}}
//Config should be a json object that contains all of the info necessary to create
//configuration xml
var LtiXmlComponent = Ember.Component.extend({
  valid_options: [
    "url", "icon_url", "text", "selection_width", "selection_height",
    "enabled", "visibility", "default"
  ],

  xml: function() {
    var configXML = $('<cartridge_basiclti_link>')
      .attr("xmlns", "http://www.imsglobal.org/xsd/imslticc_v1p0")
      .attr("xmlns:blti", 'http://www.imsglobal.org/xsd/imsbasiclti_v1p0')
      .attr("xmlns:lticm", 'http://www.imsglobal.org/xsd/imslticm_v1p0')
      .attr("xmlns:lticp", 'http://www.imsglobal.org/xsd/imslticp_v1p0')
      .attr("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
      .attr("xsi:schemaLocation", "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0p1.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd");

    configXML.append($('<blti:title>').append(config.title))
      .append($('<blti:description>').append(config.description))
      .append($('<blti:launch_url>').append(config.launch_url));

    if(config.icon_url)
      configXML.append($('<blti:icon>').append(config.icon_url));

    configXML.append(this.custom_fields());

    configXML.append(
      $('<blti:extensions>').attr("platform", "canvas.instructure.com")
        .append(this.ext_property("tool_id", config))
        .append(this.ext_property("icon_url", config))
        .append(this.ext_property("domain", config))
        .append(this.ext_property("privacy_level", config))
        .append(this.ext_property("selection_width", config))
        .append(this.ext_property("selection_height", config))
        .append(this.ext_property("text", config))

        .append(this.ext_option("account_navigation"))
        .append(this.ext_option("course_navigation"))
        .append(this.ext_option("user_navigation"))
        .append(this.ext_option("editor_button"))
        .append(this.ext_option("resource_selection"))
        .append(this.ext_option("homework_submission"))
    );

    return $('<div>').append(configXML).html();

  }.property('config'),

  ext_property: function(property, params){
    if(params[property])
      return $('<lticm:property>')
        .append(params[property])
        .attr('name', property);
    else
      return $();
  },

  ext_option: function(name){
    if(config[name]){
      var option = $('<lticm:options>').attr('name', name);
      for (var i = 0; i < this.valid_options.length; i++) {
        option.append(this.ext_property(this.valid_options[i], config[name]));
      }
      return option;
    } else {
      return $();
    }
  },

  custom_fields: function(){
    if(config.custom_fields){
      var custom = $('<blti:custom>');
      for (var i = 0; i < config.custom_fields.length; i++) {
        custom.append(
          $('<lticm:property>')
            .append(config.custom_fields[i].value)
            .attr('name', config.custom_fields[i].name)
        );
      }
      return custom;
    } else{
      return $();
    }
  }
});

module.exports = LtiXmlComponent;