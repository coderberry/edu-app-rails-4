# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

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
