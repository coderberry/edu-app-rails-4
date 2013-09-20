require 'spec_helper'

describe "LtiApps" do
  before(:each) do
    @organization = Organization.create(name: "My Test Organization", is_list_apps_without_approval: false)
    @api_key = @organization.regenerate_api_key
    @app_1 = FactoryGirl.create(:lti_app, short_name: "app_1")
    @app_2 = FactoryGirl.create(:lti_app, short_name: "app_2")
    @app_3 = FactoryGirl.create(:lti_app, short_name: "app_3")
    whitelist = @organization.whitelist
    @organization.lti_apps_organizations.where(lti_app_id: @app_1.id).first.update_attribute(:is_visible, true)
  end
  
  describe "GET /api/v1/lti_apps" do
    describe "without token" do
      it "gets list" do
        get '/api/v1/lti_apps'
        response.status.should be(200)
        json = JSON.parse(response.body)
        json.size.should == 3
      end
    end

    describe "with token" do
      it "gets list" do
        get '/api/v1/lti_apps', {}, { 'Authorization' => "Bearer #{@api_key.access_token}" }
        response.status.should be(200)
        json = JSON.parse(response.body)
        json.size.should == 1
      end
    end
  end

  describe "GET /api/v1/lti_apps/:name" do
    describe "without token" do
      it "gets item" do
        get "/api/v1/lti_apps/#{@app_1.short_name}"
        json = JSON.parse(response.body)
        json['id'].should eq(@app_1.id)
      end
    end

    describe "with token" do
      it "gets whitelisted item" do
        get "/api/v1/lti_apps/#{@app_1.short_name}", {}, { 'Authorization' => "Bearer #{@api_key.access_token}" }
        json = JSON.parse(response.body)
        json['id'].should eq(@app_1.id)
      end

      it "gets item not on whitelist" do
        get "/api/v1/lti_apps/#{@app_2.short_name}", {}, { 'Authorization' => "Bearer #{@api_key.access_token}" }
        response.status.should be(404)
      end
    end
  end
end
