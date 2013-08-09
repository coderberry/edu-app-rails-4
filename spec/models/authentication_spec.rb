require 'spec_helper'

describe Authentication do
  let(:twitter) { FactoryGirl.build(:twitter) }
  let(:google) { FactoryGirl.build(:google_oauth2)  }

  it "creates a new user" do
    Authentication.from_omniauth(twitter)
    Authentication.where(twitter.slice("provider", "uid")).first.user.should_not be_nil
  end

  it "finds existing users based on provider id" do
    auth = Authentication.from_omniauth(twitter)
    auth.should == Authentication.from_omniauth(twitter)
  end

  it "finds existing users based on email" do
    email = 'a@b.c'
    auth = Authentication.from_omniauth(twitter)
    auth.user.update_attributes(email: email)
    auth.user.should == Authentication.from_omniauth(google, email).user
  end

  it "finds and merges with existing user based on twitter nickname" do
    user = User.create!(name: twitter['info']['nickname'],
                 twitter_nickname: twitter['info']['nickname'],
                 is_omniauthing: true)

    auth = Authentication.from_omniauth(twitter)
    User.where(twitter_nickname: twitter['info']['nickname']).count.should == 0
  end

  it "updates user info during login" do
    Authentication.from_omniauth(twitter)
    twitter['info'] = {
        'nickname' => 'twit',
        'name' => 'Updated name',
        'image' => 'http://www.example.com/image.ico'
    }

    auth = Authentication.from_omniauth(twitter)
    auth.data.should == twitter['info']
  end

  it "Merges with a duplicate user" do
    twitter_auth = Authentication.from_omniauth(twitter)
    user = Authentication.from_omniauth(google).user
    Authentication.from_omniauth(twitter, nil, user)
    user.authentications.should include(twitter_auth)
 end
end
