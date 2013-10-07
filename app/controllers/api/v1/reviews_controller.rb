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
          membership = organization.memberships.where(remote_uid: params['user_id']).first()
          unless membership
            #create the user, membership, and review
            user = User.where("lower(email) = lower(?)", params[:user_email]).first_or_create(
                name: params[:user_name],
                email: ( params[:user_email] ? params[:user_email].downcase : nil ),
                avatar_url: params[:user_avatar_url],
                url: params[:user_url]
            )

            return render json: {user: user.errors.messages}, status: 422 if user.invalid?

            membership = organization.memberships.where(user_id: user.id).first_or_create(
                organization_id: organization.id,
                user_id: user.id,
                remote_uid: params[:user_id],
                is_admin: false
            )

            return render json: {membership: membership.errors.messages}, status: 422 if membership.invalid?
          end

          binding.pry

          review = Review.where(user_id: membership.user_id).first_or_create(
              lti_app_id: @lti_app.id,
              membership_id: membership.id,
              user_id: membership.user_id
          )

          review.update(
              rating: params[:rating],
              comments: params[:comments]
          )

          if review.invalid?
            render json: {review: { errors: review.errors.messages }}, status: 422 if review.invalid?
          else
            render json: review, status: 201
          end

        else
          render json: { error: 'Missing access token' }, status: 422
        end
      end

    private

      def load_lti_app
        @lti_app = LtiApp.where(id: params[:lti_app_id]).first ||
            LtiApp.where(short_name: params[:lti_app_id]).first
        unless @lti_app
          render json: {}, status: 404
        end
      end

    end
  end
end