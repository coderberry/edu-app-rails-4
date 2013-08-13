require 'spec_helper'

describe "Reviews" do
  describe "POST /reviews" do
    before(:each) do
      @lti_app = FactoryGirl.create(:lti_app)
      @organization = FactoryGirl.create(:organization)
      @api_key = @organization.current_api_key
    end

    describe "contributing a review" do
      before(:each) do
        @data = {
          lti_app_id: @lti_app.short_name,
          access_token: @api_key.access_token,
          rating: 3,
          user_name: 'Joe Blow',
          user_email: 'joe.blow@example.com',
          user_id: '123456',
          user_url: 'http://example.com/joe.blow',
          user_avatar_url: 'http://example.com/joe-blow.png',
          comments: 'This test code is really helpful!'
        }
        @user = FactoryGirl.create(:user, email: 'something@blah.com')
        @user_api_key = @user.api_keys.active.create
      end

      it "with missing token" do
        post reviews_path, @data.merge({ access_token: nil })
        response.status.should be(422)
      end

      it "with invalid token" do
        post reviews_path, @data.merge({ access_token: 'abcde' })
        response.status.should be(422)
      end

      it "with existing user" do
        @user.reviews.count.should == 0
        @user.is_member?(@organization).should be_false
        post reviews_path, @data.merge({ user_email: @user.email })
        @user.reviews.count.should == 1
        @user.is_member?(@organization).should be_true
      end

      it "with new user" do
        User.where(email: @data[:user_email]).should_not exist
        post reviews_path, @data
        json = JSON.parse(response.body)
        user = User.where(email: @data[:user_email]).first
        user.reviews.count.should == 1
        user.is_member?(@organization).should be_true
      end
    end

    describe "retrieving reviews" do
      before(:each) do
        @lti_app = FactoryGirl.create(:lti_app)
        5.times { FactoryGirl.create(:review, { lti_app_id: @lti_app.id }) }
      end

      it "get all" do
        @lti_app.reviews.count.should eq(5)
        get reviews_path({ lti_app_id: @lti_app.short_name })
        json = JSON.parse(response.body)
        json['reviews'].count.should eq(5)
      end

      it "get one" do
        user = @lti_app.reviews.first.user
        get reviews_path({ lti_app_id: @lti_app.short_name, user_email: user.email })
        json = JSON.parse(response.body)
        json['review']['user']['name'].should == user.name
      end

      it "get one (with no reviews)" do
        get reviews_path({ lti_app_id: @lti_app.short_name, user_email: "thisdoesnotexist@example.com" })
        json = JSON.parse(response.body)
        response.status.should be(404)
        json['errors'].should match /does not exist/
      end

      it "get one (with no reviews)" do
        user = FactoryGirl.create(:user)
        get reviews_path({ lti_app_id: @lti_app.short_name, user_email: user.email })
        json = JSON.parse(response.body)
        response.status.should be(404)
        json['errors'].should match /no reviews/
      end
    end
  end
end
