require('../vendor/vkbeautify.0.99.00.beta');

//{{lti-xml config=model}}
//Config should be a json object that contains all of the info necessary to create
//configuration xml
var LtiXmlComponent = Ember.Component.extend({
  validOptions: [
    "url", "icon_url", "text", "selection_width", "selection_height",
    "enabled", "visibility", "default"
  ],

  config: function() {
    return JSON.parse(this.get('data'));
  }.property('data'),

  generateXml: function() {
    var config = this.get('config');
    var configXML = $('<cartridge_basiclti_link>')
      .attr("xmlns", "http://www.imsglobal.org/xsd/imslticc_v1p0")
      .attr("xmlns:blti", 'http://www.imsglobal.org/xsd/imsbasiclti_v1p0')
      .attr("xmlns:lticm", 'http://www.imsglobal.org/xsd/imslticm_v1p0')
      .attr("xmlns:lticp", 'http://www.imsglobal.org/xsd/imslticp_v1p0')
      .attr("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
      .attr("xsi:schemaLocation", "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0p1.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd");

    if(config.title)
      configXML.append($('<blti:title>').append(config.title));

    if(config.description)
      configXML.append($('<blti:description>').append(config.description));

    if(config.launch_url)
      configXML.append($('<blti:launch_url>').append(config.launch_url));

    if(config.icon_url)
      configXML.append($('<blti:icon>').append(config.icon_url));

    configXML.append(this.customFields());

    configXML.append(
      $('<blti:extensions>').attr("platform", "canvas.instructure.com")
        .append(this.extProperty("tool_id", config))
        .append(this.extProperty("icon_url", config))
        .append(this.extProperty("domain", config))
        .append(this.extProperty("privacy_level", config))
        .append(this.extProperty("selection_width", config))
        .append(this.extProperty("selection_height", config))
        .append(this.extProperty("text", config))

        .append(this.extOptions())
    );

    this.set('xml', $('<div>').append(configXML).html());
  }.observes('data'),

  extProperty: function(property, params){
    if(params[property])
      return $('<lticm:property>')
        .append(params[property])
        .attr('name', property);
    else
      return $();
  },

  extOptions: function(){
    var launch_types = this.get('config').launch_types;
    var element = $('<temp>');
    for(var name in launch_types){
      var option = $('<lticm:options>').attr('name', name);
      for (var i = 0; i < this.validOptions.length; i++) {
        option.append(this.extProperty(this.validOptions[i], launch_types[name]));
      }
      element.append(option);
    }
    return element.children();
  },

  customFields: function(){
    var config = this.get('config');
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
  },

  formattedCode: function() {
    var brush = new SyntaxHighlighter.brushes.Xml()
    brush.init({ toolbar: false });
    var rawCode = vkbeautify.xml(this.get('xml'), 2);
    if (!Ember.isEmpty(rawCode)) {
      return new Handlebars.SafeString(brush.getHtml(rawCode));
    }
  }.property('xml')
});

module.exports = LtiXmlComponent;