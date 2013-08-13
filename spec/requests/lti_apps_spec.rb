require 'spec_helper'

describe "LtiApps" do
  describe "GET /api/v1/lti_apps" do
    before do
      10.times { FactoryGirl.create(:lti_app) }
    end

    it "gets list" do
      get lti_apps_path
      response.status.should be(200)
      json = JSON.parse(response.body)
      json['lti_apps'].size.should > 0
    end
  end

  describe "GET /api/v1/lti_apps/:name" do
    before do
      @lti_app = FactoryGirl.create(:lti_app)
    end

    it "gets list" do
      get "/api/v1/lti_apps/#{@lti_app.short_name}"
      json = JSON.parse(response.body)
      json['lti_app']['id'].should eq(@lti_app.id)
    end
  end
end
