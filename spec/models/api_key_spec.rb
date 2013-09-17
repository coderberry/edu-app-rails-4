require 'spec_helper'

describe ApiKey do
  describe "#user" do
    it "with the tokenable as a User" do
      user = FactoryGirl.create(:user)
      api_key = user.current_api_key
      api_key.user.should == user
    end

    it "with the tokenable as an Organization" do
      organization = FactoryGirl.create(:organization)
      api_key = FactoryGirl.create(:api_key, tokenable: organization)
      api_key.user.should be_nil
    end
  end

  it "#set_expiry_date" do
    time_now = Time.parse("Feb 24 1981")
    Time.stub(:now).and_return(time_now)

    api_key = ApiKey.new
    api_key.send(:set_expiry_date)
    api_key.expired_at.should eq(time_now + 1.year)
  end

  it "#generate_access_token" do
    api_key = ApiKey.new
    api_key.send(:generate_access_token)
    api_key.access_token.should match /\S{32}/
  end
end
