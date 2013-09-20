module Api
  module V1
    class ReviewsController < BaseController
      before_action :load_lti_app

      # GET /api/v1/lti_apps/:short_name/reviews
      def index
        email = params[:user_email]
        if email.present?
          user = User.where(email: email).first
          if user
            review = @lti_app.reviews.where(user_id: user.id).first
            if review
              render json: review
            else
              render json: { errors: "There are no reviews on this app by this user" }, status: 404
            end
          else
            render json: { errors: "User does not exist" }, status: 404
          end
        else
          render json: @lti_app.reviews
        end
      end

      # POST /api/v1/lti_apps/:short_name/reviews
      # Public: Create a review for an LTI App
      #
      # rating          - Integer rating from 1 to 5.
      # user_name       - User's full name, e.g. Jon Smith.
      # user_email      - User's email address.
      # user_id         - Unique identifier for the user (for the organization).
      # user_url        - The public profile URL for the user, if any (optional).
      # user_avatar_url - The public avatar image for the comment user, if any (optional).
      # comments        - Plain text comments provided by the user (optional).
      #
      # Example POST params
      #
      #    {
      #      rating: 3,
      #      user_name: 'Jon Smith',
      #      user_email: 'jon.smith@example.com',
      #      user_id: 1993402,
      #      user_url: 'http://example.com/jonsmith',
      #      user_avatar_url: 'http://example.com/jonsmith.png',
      #      comments: 'This is a great app!'
      #    }
      def create
        @organization = organization
        if @organization
          user = User.where("lower(email) = lower(?)", params[:user_email]).first_or_create(
              name: params[:user_name], 
              email: params[:user_email].downcase,
              avatar_url: params[:user_avatar_url],
              url: params[:user_url]
          )

          membership = organization.memberships.where(user_id: user.id).first_or_create(
            organization_id: organization.id, 
            user_id: user.id, 
            remote_uid: params[:user_id], 
            is_admin: false
          )

          review = Review.create(
            lti_app_id: @lti_app.id,
            membership_id: membership.id,
            user_id: user.id,
            rating: params[:rating],
            comments: params[:comments]
          )

          if review.new_record?
            render json: { errors: review.errors.messages }, status: 422
          else
            render json: review, status: 201
          end

        else
          render json: { error: 'Missing access token' }, status: 422
        end
      end

    private

      def load_lti_app
        @lti_app = LtiApp.where(short_name: params[:lti_app_id]).first
        unless @lti_app
          render json: {}, status: 404
        end
      end

    end
  end
end