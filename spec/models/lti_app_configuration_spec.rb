require 'spec_helper'

describe LtiAppConfiguration do
  describe "#tool_config" do
    before :each do
      raw_json = <<-EOS
{
  "title": "Kitchen Sink",
  "description": "This is an example LTI configuration which has every option selected for testing purposes.",
  "iconUrl": "http://photos4.meetupstatic.com/photos/event/6/f/7/4/global_245368532.jpeg",
  "launchUrl": "https://example.com/kitchensink",
  "toolId": "kitchen_sink",
  "defaultLinkText": "Click Me",
  "defaultWidth": "500",
  "defaultHeight": "500",
  "launchPrivacy": "name_only",
  "domain": "example.com",
  "customFields": [
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
  "configOptions": [
    {
      "name": "req_w_def",
      "description": "This is a required field that has a default value",
      "type": "text",
      "defaultValue": "Something",
      "isRequired": true
    },
    {
      "name": "req_wo_def",
      "description": "This is a required field that does NOT have a default value",
      "type": "text",
      "defaultValue": "",
      "isRequired": true
    },
    {
      "name": "opt_w_def",
      "description": "This is an optional field with a default value",
      "type": "text",
      "defaultValue": "Something Else",
      "isRequired": false
    },
    {
      "name": "opt_wo_def",
      "description": "This is an optional field that does NOT have a default value",
      "type": "text",
      "defaultValue": "",
      "isRequired": false
    }
  ],
  "editorButton": {
    "isEnabled": true,
    "isOptional": false,
    "name": "editor_button",
    "launchUrl": "https://example.com/custom_launch",
    "linkText": "Custom Launch Link",
    "iconUrl": "http://example.com/custom_icon.png",
    "width": "600",
    "height": "600"
  },
  "resourceSelection": {
    "isEnabled": true,
    "isOptional": true,
    "name": "resource_selection",
    "launchUrl": "",
    "linkText": null,
    "iconUrl": null,
    "width": null,
    "height": null
  },
  "homeworkSubmission": {
    "isEnabled": true,
    "isOptional": false,
    "name": "homework_submission",
    "launchUrl": null,
    "linkText": null,
    "iconUrl": null,
    "width": null,
    "height": null
  },
  "courseNav": {
    "isEnabled": true,
    "isOptional": true,
    "name": "course_nav",
    "launchUrl": "https://example.com/kitchensink_override",
    "linkText": "{{opt_wo_def}}",
    "visibility": "admins",
    "enabledByDefault": false
  },
  "accountNav": {
    "isEnabled": true,
    "isOptional": false,
    "name": "account_nav",
    "launchUrl": null,
    "linkText": null,
    "visibility": "public",
    "enabledByDefault": true
  },
  "userNav": {
    "isEnabled": true,
    "isOptional": true,
    "name": "user_nav",
    "launchUrl": "https://example.com/user_nav",
    "linkText": "THIS IS CUSTOM: {{opt_w_def}}",
    "visibility": "public",
    "enabledByDefault": true
  }
}
    EOS
      @lti_app_configuration = LtiAppConfiguration.create(user_id: 1, config: JSON.parse(raw_json))
    end

    it "should convert to a valid cartridge" do
      @lti_app_configuration.uid.should =~ /\S{15}/
      tool = @lti_app_configuration.tool_config({ req_wo_def: 'From Param' })
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
      ext['resource_selection']['enabled'].should be_true
      ext['homework_submission']['enabled'].should be_true
      ext['course_nav']['enabled'].should be_true
      ext['course_nav']['url'].should == 'https://example.com/kitchensink_override'
      ext['account_nav']['enabled'].should be_true
      ext['user_nav']['enabled'].should be_true
      ext['user_nav']['url'].should == 'https://example.com/user_nav'
      ext['user_nav']['text'].should == 'THIS IS CUSTOM: Something Else'
    end
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
    cartridge.iconUrl.should == 'http://example.com/custom_icon.png'
    cartridge.launchUrl.should == 'https://example.com/kitchensink'
    cartridge.toolId.should == 'kitchen_sink'
    cartridge.defaultLinkText.should == 'Click Me'
    cartridge.defaultWidth.should == '500'
    cartridge.defaultHeight.should == '500'
    cartridge.launchPrivacy.should == 'name_only'
    cartridge.domain.should == 'example.com'
    cartridge.editorButton.isEnabled.should be_true
    cartridge.editorButton.iconUrl.should == 'http://example.com/custom_icon.png'
    cartridge.editorButton.width.should == '600'
    cartridge.editorButton.height.should == '600'
    cartridge.editorButton.linkText.should == 'Custom Launch Link'
    cartridge.resourceSelection.isEnabled.should be_true
    cartridge.homeworkSubmission.isEnabled.should be_true
    cartridge.courseNav.isEnabled.should be_true
    cartridge.courseNav.launchUrl.should == 'https://example.com/kitchensink_override'
    cartridge.accountNav.isEnabled.should be_true
    cartridge.userNav.isEnabled.should be_true
    cartridge.userNav.linkText.should == 'THIS IS CUSTOM: Something Else'
    cartridge.userNav.launchUrl.should == 'https://example.com/user_nav'
  end
end
