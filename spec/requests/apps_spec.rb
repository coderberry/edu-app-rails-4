require 'spec_helper'

KITCHEN_SINK = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0" xmlns:blti="http://www.imsglobal.org/xsd/imsbasiclti_v1p0" xmlns:lticm="http://www.imsglobal.org/xsd/imslticm_v1p0" xmlns:lticp="http://www.imsglobal.org/xsd/imslticp_v1p0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0p1.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
  <blti:title>Kitchen Sink</blti:title>
  <blti:description>This is an example LTI configuration which has every option selected for testing purposes.</blti:description>
  <blti:launch_url>https://example.com/kitchensink</blti:launch_url>
  <blti:icon>https://example.com/icon.ico</blti:icon>
  <blti:custom>
    <lticm:property name="another_custom_field">{{opt_w_def}}</lticm:property>
    <lticm:property name="req_w_def">{{req_w_def}}</lticm:property>
    <lticm:property name="req_wo_def">{{req_wo_def}}</lticm:property>
  </blti:custom>
  <blti:extensions platform="canvas.instructure.com">
    <lticm:options name="account_navigation">
      <lticm:property name="enabled">true</lticm:property>
    </lticm:options>
    <lticm:options name="course_navigation">
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
    <lticm:options name="user_navigation">
      <lticm:property name="enabled">true</lticm:property>
      <lticm:property name="text">THIS IS CUSTOM: {{opt_wo_def}}</lticm:property>
      <lticm:property name="url">https://example.com/user_nav</lticm:property>
    </lticm:options>
  </blti:extensions>
</cartridge_basiclti_link>
EOS

describe "Apps" do
  before :each do
    @user = User.create(
      is_registering: true,
      name: 'Foo Bar',
      email: 'foo@example.com',
      password: 'secret',
      password_confirmation: 'secret')
  end

  describe "/apps/new", type: :feature do
    before :each do 
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
      visit new_lti_app_path
      expect(page).to have_content 'Submit an App'
    end

    it "creates an app with config options", js: true do
      find('input[name="cartridge_source"][value="xml"]').click
      fill_in 'xml', with: KITCHEN_SINK
      find('#lti_app_is_public_true').click
      fill_in 'lti_app_short_name', with: 'kitchen_sink'
      fill_in 'lti_app_name', with: 'Kitchen Sink'
      fill_in 'lti_app_author_name', with: 'Joe Blow'
      fill_in 'lti_app_preview_url', with: 'http://vimeo-lti.herokuapp.com'
      fill_in 'lti_app_banner_image_url', with: 'http://vimeo-lti.herokuapp.com/images/banner.png'
      
      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('req_w_def')")
      page.execute_script("$('.fields tr:last input[rel=\"default_value\"]').val('REQ DEF VALUE')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Required w/ Default')")
      page.execute_script("$('.fields tr:last input[rel=\"is_required\"]').click()")

      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('req_wo_def')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Required w/o Default')")
      page.execute_script("$('.fields tr:last input[rel=\"is_required\"]').click()")
      
      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('opt_w_def')")
      page.execute_script("$('.fields tr:last input[rel=\"default_value\"]').val('OPT DEF VALUE')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Optional w/ Default')")

      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('opt_wo_def')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Optional w/o Default')")
      
      click_button 'Save Changes'
      expect(page).to have_content '* Required w/ Default'
    end
  end
end
