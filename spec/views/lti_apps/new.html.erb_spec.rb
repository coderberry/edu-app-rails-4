require 'spec_helper'

describe "lti_apps/new" do
  before(:each) do
    assign(:lti_app, stub_model(LtiApp,
      :user => nil,
      :short_name => "MyString",
      :name => "MyString",
      :description => "MyText",
      :status => "MyString",
      :testing_instructions => "MyText",
      :support_url => "MyString",
      :author_name => "MyString",
      :is_public => false,
      :app_type => "MyString",
      :ims_cert_url => "MyString",
      :preview_url => "MyString",
      :config_url => "MyString",
      :data_url => "MyString",
      :cartridge => "",
      :banner_image_url => "MyString",
      :logo_image_url => "MyString",
      :short_description => "MyString"
    ).as_new_record)
  end

  it "renders new lti_app form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", lti_apps_path, "post" do
      assert_select "input#lti_app_user[name=?]", "lti_app[user]"
      assert_select "input#lti_app_short_name[name=?]", "lti_app[short_name]"
      assert_select "input#lti_app_name[name=?]", "lti_app[name]"
      assert_select "textarea#lti_app_description[name=?]", "lti_app[description]"
      assert_select "input#lti_app_status[name=?]", "lti_app[status]"
      assert_select "textarea#lti_app_testing_instructions[name=?]", "lti_app[testing_instructions]"
      assert_select "input#lti_app_support_url[name=?]", "lti_app[support_url]"
      assert_select "input#lti_app_author_name[name=?]", "lti_app[author_name]"
      assert_select "input#lti_app_is_public[name=?]", "lti_app[is_public]"
      assert_select "input#lti_app_app_type[name=?]", "lti_app[app_type]"
      assert_select "input#lti_app_ims_cert_url[name=?]", "lti_app[ims_cert_url]"
      assert_select "input#lti_app_preview_url[name=?]", "lti_app[preview_url]"
      assert_select "input#lti_app_config_url[name=?]", "lti_app[config_url]"
      assert_select "input#lti_app_data_url[name=?]", "lti_app[data_url]"
      assert_select "input#lti_app_cartridge[name=?]", "lti_app[cartridge]"
      assert_select "input#lti_app_banner_image_url[name=?]", "lti_app[banner_image_url]"
      assert_select "input#lti_app_logo_image_url[name=?]", "lti_app[logo_image_url]"
      assert_select "input#lti_app_short_description[name=?]", "lti_app[short_description]"
    end
  end
end
