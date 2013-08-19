require 'spec_helper'

describe User do

  it "#with_access_token" do
    user = User.create!(name: 'Foo Bar', email: 'foo@example.com')
    api_key = user.current_api_key
    User.with_access_token(api_key.access_token).id.should eq(user.id)
  end

  describe "create directly (no omniauth nor via reviews)" do
    it "requires email and password" do
      user = User.new(is_registering: true)
      user.should_not be_valid
      user.errors.has_key?(:email).should be_true
      user.errors.has_key?(:password).should be_true
    end

    it "creates a user" do
      user = User.create(
        is_registering: true,
        name: 'Foo Bar',
        email: 'foo@example.com',
        password: 'secret',
        password_confirmation: 'secret')
      user.new_record?.should be_false
    end
  end

  describe "create indirectly (via reviews)" do
    it "requires email but not password" do
      user = User.new
      user.should_not be_valid
      user.errors.has_key?(:email).should be_true
      user.errors.has_key?(:password).should be_false
    end

    it "creates a user" do
      user = User.create(
        name: 'Foo Bar',
        email: 'foo@example.com')
      user.new_record?.should be_false
    end
  end

  describe "create via omniauth" do
    it "does not require email nor password" do
      user = User.new(is_omniauthing: true)
      user.should_not be_valid
      user.errors.has_key?(:name).should be_true
      user.errors.has_key?(:email).should be_false
      user.errors.has_key?(:password).should be_false
    end

    it "creates a user" do
      user = User.create(
        is_omniauthing: true,
        name: 'Foo Bar')
      user.new_record?.should be_false
    end
  end

  describe "#merge" do
    let(:user1) {User.create!(name: 'Foo Bar', email: 'foo@example.com')}
    let(:user2) {User.create!(name: 'Bar Foo', email: 'bar@example.com')}
    let(:org1) {Organization.create!(name: 'org1')}
    let(:org2) {Organization.create!(name: 'org2')}
    let(:org3) {Organization.create!(name: 'org3')}
    let(:org4) {Organization.create!(name: 'or43')}

    it "merges user data" do
      user2.update_attributes(
          password_digest: password_digest = '123456789',
          avatar_url: avatar_url = 'http://www.example.com/avatar',
          url: url = 'http://www.example.com/',
          twitter_nickname: twitter_nickname = 'foo_bar'
      )

      user1.merge(user2)

      user1.name.should == 'Foo Bar'
      user1.email.should == 'foo@example.com'
      user1.password_digest.should == password_digest
      user1.avatar_url.should == avatar_url
      user1.url.should == url
      user1.twitter_nickname.should == nil
    end

    it "merges memberships" do
      Membership.create(user: user1, organization: org1)
      Membership.create(user: user1, organization: org3, remote_uid: '123456')
      Membership.create(user: user1, organization: org4, remote_uid: '567890')
      Membership.create(user: user2, organization: org2)
      Membership.create(user: user2, organization: org3, is_admin: true, remote_uid: '654321')
      Membership.create(user: user2, organization: org4, remote_uid: '098765')

      user1.merge(user2)

      user1.memberships.count.should == 4
      membership = user1.memberships.where(organization: org3).first
      membership.is_admin.should be_true
      membership.remote_uid.should == '654321'

      membership = user1.memberships.where(organization: org4).first
      membership.remote_uid.should == '567890'
    end

    it "merges reviews" do
      reviews = []

      Review.record_timestamps = false
      app1 = FactoryGirl.create(:lti_app, short_name: 'app1')
      Review.create(user: user1, lti_app: app1 , rating: 3, updated_at: 10.minutes.ago)
      reviews << Review.create(user: user2, lti_app: app1, rating: 4, updated_at: 9.minutes.ago)

      app2 = FactoryGirl.create(:lti_app, short_name: 'app2')
      Review.create(user: user2, lti_app: app2, rating: 3, updated_at: 8.minutes.ago)
      reviews << Review.create(user: user1, lti_app: app2, rating: 4, updated_at: 7.minutes.ago)

      reviews << Review.create(user: user1, lti_app: FactoryGirl.create(:lti_app, short_name: 'app3'), rating: 4, updated_at: 6.minutes.ago)
      reviews << Review.create(user: user2, lti_app: FactoryGirl.create(:lti_app, short_name: 'app4'), rating: 4, updated_at: 5.minutes.ago)

      user1.merge(user2)

      user1.reload
      user1.reviews.count.should == reviews.count
      user1.reviews.should include(*reviews)
    end

    it "merges authentications" do
      auths = []
      auths << Authentication.create_from_omniauth(FactoryGirl.build(:twitter), nil, user1)
      auths << Authentication.create_from_omniauth(FactoryGirl.build(:google_oauth2), nil, user1)

      Authentication.create_from_omniauth(FactoryGirl.build(:google_oauth2), nil, user2)
      auths << Authentication.create_from_omniauth(FactoryGirl.build(:facebook), nil, user2)

      user1.merge(user2)

      user1.reload
      user1.authentications.count.should == auths.count
      user1.authentications.should include(*auths)
    end

    it "deletes the old user" do
      user1.merge(user2)

      User.should_not be_exists(user2)
    end
  end
end
