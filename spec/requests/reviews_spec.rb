require 'spec_helper'

describe "Reviews" do
  describe "POST /api/v1/reviews" do
    before(:each) do
      @lti_app = FactoryGirl.create(:lti_app)
      @organization = FactoryGirl.create(:organization)
      @api_key = @organization.current_api_key
    end

    describe "contributing a review" do
      before(:each) do
        @data = {
          rating: 3,
          user_name: 'Joe Blow',
          user_email: 'joe.blow@example.com',
          user_id: '123456',
          user_url: 'http://example.com/joe.blow',
          user_avatar_url: 'http://example.com/joe-blow.png',
          comments: 'This test code is really helpful!'
        }
      end

      it "with missing token" do
        post api_v1_lti_app_reviews_path(@lti_app.short_name), @data
        response.status.should be(422)
      end

      it "with invalid token" do
        post api_v1_lti_app_reviews_path(@lti_app.short_name), @data, { 'Authorization' => "Bearer BAD" }
        response.status.should be(422)
      end

      it "with existing user" do
        @user = FactoryGirl.create(:user, email: "jane.blow@example.com")
        @user.reviews.count.should == 0
        @user.is_member?(@organization).should be_false
        post api_v1_lti_app_reviews_path(@lti_app.short_name), @data.merge({ user_email: @user.email }), { 'Authorization' => "Bearer #{@api_key.access_token}" }
        @user.reviews.count.should == 1
        @user.is_member?(@organization).should be_true
      end

      it "with new user" do
        User.where(email: @data[:user_email]).should_not exist
        post api_v1_lti_app_reviews_path(@lti_app.short_name), @data, { 'Authorization' => "Bearer #{@api_key.access_token}" }
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
        get api_v1_lti_app_reviews_path(@lti_app.short_name)
        json = JSON.parse(response.body)
        json['reviews'].count.should eq(5)
      end

      it "get one" do
        user = @lti_app.reviews.first.user
        get api_v1_lti_app_reviews_path(@lti_app.short_name, { user_email: user.email })
        json = JSON.parse(response.body)
        json['review']['user']['name'].should == user.name
      end

      it "get one (with no reviews)" do
        get api_v1_lti_app_reviews_path(@lti_app.short_name, { user_email: "thisdoesnotexist@example.com" })
        json = JSON.parse(response.body)
        response.status.should be(404)
        json['errors'].should match /does not exist/
      end

      it "get one (with no reviews)" do
        user = FactoryGirl.create(:user)
        get api_v1_lti_app_reviews_path(@lti_app.short_name, { user_email: user.email })
        json = JSON.parse(response.body)
        response.status.should be(404)
        json['errors'].should match /no reviews/
      end
    end
  end
end
