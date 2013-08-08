require 'spec_helper'

describe "lti_apps/index" do
  before(:each) do
    assign(:lti_apps, [
      stub_model(LtiApp,
        :user => nil,
        :short_name => "Short Name",
        :name => "Name",
        :description => "MyText",
        :status => "Status",
        :testing_instructions => "MyText",
        :support_url => "Support Url",
        :author_name => "Author Name",
        :is_public => false,
        :app_type => "App Type",
        :ims_cert_url => "Ims Cert Url",
        :preview_url => "Preview Url",
        :config_url => "Config Url",
        :data_url => "Data Url",
        :cartridge => "",
        :banner_image_url => "Banner Image Url",
        :logo_image_url => "Logo Image Url",
        :short_description => "Short Description"
      ),
      stub_model(LtiApp,
        :user => nil,
        :short_name => "Short Name",
        :name => "Name",
        :description => "MyText",
        :status => "Status",
        :testing_instructions => "MyText",
        :support_url => "Support Url",
        :author_name => "Author Name",
        :is_public => false,
        :app_type => "App Type",
        :ims_cert_url => "Ims Cert Url",
        :preview_url => "Preview Url",
        :config_url => "Config Url",
        :data_url => "Data Url",
        :cartridge => "",
        :banner_image_url => "Banner Image Url",
        :logo_image_url => "Logo Image Url",
        :short_description => "Short Description"
      )
    ])
  end

  it "renders a list of lti_apps" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Short Name".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Support Url".to_s, :count => 2
    assert_select "tr>td", :text => "Author Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "App Type".to_s, :count => 2
    assert_select "tr>td", :text => "Ims Cert Url".to_s, :count => 2
    assert_select "tr>td", :text => "Preview Url".to_s, :count => 2
    assert_select "tr>td", :text => "Config Url".to_s, :count => 2
    assert_select "tr>td", :text => "Data Url".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Banner Image Url".to_s, :count => 2
    assert_select "tr>td", :text => "Logo Image Url".to_s, :count => 2
    assert_select "tr>td", :text => "Short Description".to_s, :count => 2
  end
end
