require 'spec_helper'

describe "Cartridges" do
  before do
    @user = FactoryGirl.create(:user)
    @cartridge_1 = FactoryGirl.create(:cartridge, { user: @user })
    @cartridge_2 = FactoryGirl.create(:cartridge, { user: @user })
    @cartridge_3 = FactoryGirl.create(:cartridge, { user: @user })
    @token = @user.current_api_key.access_token
  end

  after do
    session[:user_id] = nil
  end

  describe "GET /api/v1/cartridges" do
    it "gets list" do
      get "/api/v1/cartridges?token=#{@token}"
      response.status.should be(200)
      json = JSON.parse(response.body)
      json['cartridges'].size.should == 3
    end
  end

  describe "GET /api/v1/cartridges/:uid" do
    it "gets list" do
      get "/api/v1/cartridges/#{@cartridge_1.uid}"
      json = JSON.parse(response.body)
      json['cartridge']['uid'].should eq(@cartridge_1.uid)
      json['cartridge']['name'].should eq(@cartridge_1.name)
    end
  end
end
