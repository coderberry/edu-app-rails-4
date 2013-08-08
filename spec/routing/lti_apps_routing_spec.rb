require "spec_helper"

describe LtiAppsController do
  describe "routing" do

    it "routes to #index" do
      get("/lti_apps").should route_to("lti_apps#index")
    end

    it "routes to #new" do
      get("/lti_apps/new").should route_to("lti_apps#new")
    end

    it "routes to #show" do
      get("/lti_apps/1").should route_to("lti_apps#show", :id => "1")
    end

    it "routes to #edit" do
      get("/lti_apps/1/edit").should route_to("lti_apps#edit", :id => "1")
    end

    it "routes to #create" do
      post("/lti_apps").should route_to("lti_apps#create")
    end

    it "routes to #update" do
      put("/lti_apps/1").should route_to("lti_apps#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/lti_apps/1").should route_to("lti_apps#destroy", :id => "1")
    end

  end
end
