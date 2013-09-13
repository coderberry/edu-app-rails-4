require 'spec_helper'

describe LtiAppConfiguration do
  describe "#tool_config" do
    before :each do
      raw_json = <<-EOS
{
  "title": "Kitchen Sink",
  "description": "This is an example LTI configuration which has every option selected for testing purposes.",
  "icon_url": "http://photos4.meetupstatic.com/photos/event/6/f/7/4/global_245368532.jpeg",
  "launch_url": "https://example.com/kitchensink",
  "tool_id": "kitchen_sink",
  "text": "Click Me",
  "default_width": "500",
  "default_height": "500",
  "privacy_level": "name_only",
  "domain": "example.com",
  "custom_fields": [
    {
      "name": "req_w_def",
      "value": "{{req_w_def}}"
    },
    {
      "name": "req_wo_def",
      "value": "{{req_wo_def}}"
    },
    {
      "name": "another_custom_field",
      "value": "WHOOP!"
    }
  ],
  "config_options": [
    {
      "name": "req_w_def",
      "description": "This is a required field that has a default value",
      "type": "text",
      "default_value": "Something",
      "is_required": true
    },
    {
      "name": "req_wo_def",
      "description": "This is a required field that does NOT have a default value",
      "type": "text",
      "default_value": "",
      "is_required": true
    },
    {
      "name": "opt_w_def",
      "description": "This is an optional field with a default value",
      "type": "text",
      "default_value": "Something Else",
      "is_required": false
    },
    {
      "name": "opt_wo_def",
      "description": "This is an optional field that does NOT have a default value",
      "type": "text",
      "default_value": "",
      "is_required": false
    }
  ],
  "optional_launch_types": [
    "resource_selection",
    "course_navigation",
    "user_navigation"
  ],
  "launch_types": {
    "editor_button": {
      "enabled": true,
      "url": "https://example.com/custom_launch",
      "text": "Custom Launch Link",
      "icon_url": "http://example.com/custom_icon.png",
      "selection_width": "600",
      "selection_height": "600"
    },
    "resource_selection": {
      "enabled": true,
      "url": "",
      "text": null,
      "icon_url": null,
      "selection_width": null,
      "selection_height": null
    },
    "homework_submission": {
      "enabled": true,
      "url": null,
      "text": null,
      "icon_url": null,
      "selection_width": null,
      "selection_height": null
    },
    "course_navigation": {
      "enabled": true,
      "url": "https://example.com/kitchensink_override",
      "text": "{{opt_wo_def}}",
      "visibility": "admins",
      "enabled_by_default": false
    },
    "account_navigation": {
      "enabled": true,
      "url": null,
      "text": null,
      "visibility": "public",
      "enabled_by_default": true
    },
    "user_navigation": {
      "enabled": true,
      "url": "https://example.com/user_navigation",
      "text": "THIS IS CUSTOM: {{opt_w_def}}",
      "visibility": "public",
      "enabled_by_default": true
    }
  }
}
    EOS
      @lti_app_configuration = LtiAppConfiguration.create(user_id: 1, config: JSON.parse(raw_json))
    end

    it "should convert to a valid cartridge" do
      @lti_app_configuration.uid.should =~ /\S{15}/
      tool = @lti_app_configuration.tool_config({ req_wo_def: 'From Param', course_navigation: 1, user_navigation: 1 })
      tool.title.should == 'Kitchen Sink'
      tool.description.should == 'This is an example LTI configuration which has every option selected for testing purposes.'
      tool.icon.should == 'http://photos4.meetupstatic.com/photos/event/6/f/7/4/global_245368532.jpeg'
      tool.launch_url.should == 'https://example.com/kitchensink'

      tool.custom_params['req_w_def'].should == 'Something'
      tool.custom_params['req_wo_def'].should == 'From Param'
      tool.custom_params['another_custom_field'].should == 'WHOOP!'

      ext = tool.extensions.first.last
      ext['tool_id'].should == 'kitchen_sink'
      ext['link_text'].should == 'Click Me'
      ext['selection_width'].should == '500'
      ext['selection_height'].should == '500'
      ext['privacy_level'].should == 'name_only'
      ext['domain'].should == 'example.com'

      ext['editor_button']['enabled'].should be_true
      ext['editor_button']['icon_url'].should == 'http://example.com/custom_icon.png'
      ext['editor_button']['selection_width'].should == '600'
      ext['editor_button']['selection_height'].should == '600'
      ext['editor_button']['text'].should == 'Custom Launch Link'
      ext['resource_selection'].should be_nil
      ext['homework_submission']['enabled'].should be_true
      ext['course_navigation']['enabled'].should be_true
      ext['course_navigation']['url'].should == 'https://example.com/kitchensink_override'
      ext['account_navigation']['enabled'].should be_true
      ext['user_navigation']['enabled'].should be_true
      ext['user_navigation']['url'].should == 'https://example.com/user_navigation'
      ext['user_navigation']['text'].should == 'THIS IS CUSTOM: Something Else'
    end
  end

  it "foo" do
    xml = <<-EOS

<?xml version="1.0" encoding="UTF-8"?>
<cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0"
    xmlns:blti = "http://www.imsglobal.org/xsd/imsbasiclti_v1p0"
    xmlns:lticm ="http://www.imsglobal.org/xsd/imslticm_v1p0"
    xmlns:lticp ="http://www.imsglobal.org/xsd/imslticp_v1p0"
    xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation = "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd
    http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
  <blti:title>YouTube</blti:title>
  <blti:description>Search publicly available YouTube videos. A new icon will show up in your course rich editor letting you search YouTube and click to embed videos in your course material.</blti:description>
  <blti:icon>http://www.edu-apps.org/tools/youtube/icon.png</blti:icon>
  <blti:launch_url>http://www.edu-apps.org/tool_redirect?id=youtube</blti:launch_url>
  <blti:extensions platform="canvas.instructure.com">
    <lticm:property name="tool_id">youtube</lticm:property>
    <lticm:property name="privacy_level">anonymous</lticm:property>
    <lticm:options name="editor_button">
      <lticm:property name="url">http://www.edu-apps.org/tool_redirect?id=youtube</lticm:property>
      <lticm:property name="icon_url">http://www.edu-apps.org/tools/youtube/icon.png</lticm:property>
      <lticm:property name="text">YouTube</lticm:property>
      <lticm:property name="selection_width">690</lticm:property>
      <lticm:property name="selection_height">530</lticm:property>
      <lticm:property name="enabled">true</lticm:property>
    </lticm:options>
    <lticm:options name="resource_selection">
      <lticm:property name="url">http://www.edu-apps.org/tool_redirect?id=youtube</lticm:property>
      <lticm:property name="icon_url">http://www.edu-apps.org/tools/youtube/icon.png</lticm:property>
      <lticm:property name="text">YouTube</lticm:property>
      <lticm:property name="selection_width">690</lticm:property>
      <lticm:property name="selection_height">530</lticm:property>
      <lticm:property name="enabled">true</lticm:property>
    </lticm:options>
  </blti:extensions>
  <cartridge_bundle identifierref="BLTI001_Bundle"/>
  <cartridge_icon identifierref="BLTI001_Icon"/>
</cartridge_basiclti_link>  
EOS
    cartridge = LtiAppConfiguration.xml_to_cartridge(xml)

    cartridge.title.should == 'YouTube'
    cartridge.launch_url.should == 'http://www.edu-apps.org/tool_redirect?id=youtube'
    cartridge.tool_id.should == 'youtube'
  end

  it ".xml_to_json" do
    xml = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0" xmlns:blti="http://www.imsglobal.org/xsd/imsbasiclti_v1p0" xmlns:lticm="http://www.imsglobal.org/xsd/imslticm_v1p0" xmlns:lticp="http://www.imsglobal.org/xsd/imslticp_v1p0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0p1.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
  <blti:title>Kitchen Sink</blti:title>
  <blti:description>This is an example LTI configuration which has every option selected for testing purposes.</blti:description>
  <blti:launch_url>https://example.com/kitchensink</blti:launch_url>
  <blti:custom>
    <lticm:property name="another_custom_field">WHOOP!</lticm:property>
    <lticm:property name="req_w_def">Something</lticm:property>
    <lticm:property name="req_wo_def">REQ_WO_DEF</lticm:property>
  </blti:custom>
  <blti:extensions platform="canvas.instructure.com">
    <lticm:options name="account_nav">
      <lticm:property name="enabled">true</lticm:property>
    </lticm:options>
    <lticm:options name="course_nav">
      <lticm:property name="enabled">true</lticm:property>
      <lticm:property name="text"/>
      <lticm:property name="url">https://example.com/kitchensink_override</lticm:property>
    </lticm:options>
    <lticm:property name="domain">example.com</lticm:property>
    <lticm:options name="editor_button">
      <lticm:property name="enabled">true</lticm:property>
      <lticm:property name="icon_url">http://example.com/custom_icon.png</lticm:property>
      <lticm:property name="selection_height">600</lticm:property>
      <lticm:property name="selection_width">600</lticm:property>
      <lticm:property name="text">Custom Launch Link</lticm:property>
    </lticm:options>
    <lticm:options name="homework_submission">
      <lticm:property name="enabled">true</lticm:property>
    </lticm:options>
    <lticm:property name="link_text">Click Me</lticm:property>
    <lticm:property name="privacy_level">name_only</lticm:property>
    <lticm:options name="resource_selection">
      <lticm:property name="enabled">true</lticm:property>
    </lticm:options>
    <lticm:property name="selection_height">500</lticm:property>
    <lticm:property name="selection_width">500</lticm:property>
    <lticm:property name="tool_id">kitchen_sink</lticm:property>
    <lticm:options name="user_nav">
      <lticm:property name="enabled">true</lticm:property>
      <lticm:property name="text">THIS IS CUSTOM: Something Else</lticm:property>
      <lticm:property name="url">https://example.com/user_nav</lticm:property>
    </lticm:options>
  </blti:extensions>
</cartridge_basiclti_link>
    EOS

    cartridge = LtiAppConfiguration.xml_to_cartridge(xml)

    cartridge.title.should == 'Kitchen Sink'
    cartridge.description.should == 'This is an example LTI configuration which has every option selected for testing purposes.'
    cartridge.icon_url.should == 'http://example.com/custom_icon.png'
    cartridge.launch_url.should == 'https://example.com/kitchensink'
    cartridge.tool_id.should == 'kitchen_sink'
    cartridge.text.should == 'Click Me'
    cartridge.default_width.should == '500'
    cartridge.default_height.should == '500'
    cartridge.privacy_level.should == 'name_only'
    cartridge.domain.should == 'example.com'
    cartridge.editor_button.enabled.should be_true
    cartridge.editor_button.icon_url.should == 'http://example.com/custom_icon.png'
    cartridge.editor_button.selection_width.should == '600'
    cartridge.editor_button.selection_height.should == '600'
    cartridge.editor_button.text.should == 'Custom Launch Link'
    cartridge.resource_selection.enabled.should be_true
    cartridge.homework_submission.enabled.should be_true
    cartridge.course_navigation.enabled.should be_true
    cartridge.course_navigation.url.should == 'https://example.com/kitchensink_override'
    cartridge.account_navigation.enabled.should be_true
    cartridge.user_navigation.enabled.should be_true
    cartridge.user_navigation.text.should == 'THIS IS CUSTOM: Something Else'
    cartridge.user_navigation.url.should == 'https://example.com/user_nav'
  end
end
