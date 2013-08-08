require 'spec_helper'

describe "lti_apps/show" do
  before(:each) do
    @lti_app = assign(:lti_app, stub_model(LtiApp,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(/Short Name/)
    rendered.should match(/Name/)
    rendered.should match(/MyText/)
    rendered.should match(/Status/)
    rendered.should match(/MyText/)
    rendered.should match(/Support Url/)
    rendered.should match(/Author Name/)
    rendered.should match(/false/)
    rendered.should match(/App Type/)
    rendered.should match(/Ims Cert Url/)
    rendered.should match(/Preview Url/)
    rendered.should match(/Config Url/)
    rendered.should match(/Data Url/)
    rendered.should match(//)
    rendered.should match(/Banner Image Url/)
    rendered.should match(/Logo Image Url/)
    rendered.should match(/Short Description/)
  end
end
