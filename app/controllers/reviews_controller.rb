class ReviewsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_review, only: [:show]
  before_action :load_lti_app, except: :show

  # GET /reviews
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

  # GET /reviews/1
  def show
    render json: @review
  end

  # Public: Create a review for an LTI App
  #
  # access_token    - The access token which is tied to either an organization or user.
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
  #      access_token: 'abcdefg',
  #      rating: 3,
  #      user_name: 'Jon Smith',
  #      user_email: 'jon.smith@example.com',
  #      user_id: 1993402,
  #      user_url: 'http://example.com/jonsmith',
  #      user_avatar_url: 'http://example.com/jonsmith.png',
  #      comments: 'This is a great app!'
  #    }
  #
  # Returns the created review (JSON)
  def create
    api_key = ApiKey.active.where(access_token: params[:access_token]).first
    if api_key
      if organization = api_key.organization
        user = User.where("lower(email) = lower(?)", params[:user_email]).first
        unless user
          user = User.create!(
            name: params[:user_name], 
            email: params[:user_email].downcase,
            avatar_url: params[:user_avatar_url],
            url: params[:user_url]
          )
        end

        membership = organization.memberships.where(user_id: user.id).first
        unless membership
          membership = Membership.create!(organization_id: organization.id, user_id: user.id, remote_uid: params[:user_id], is_admin: false)
        end

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

      else # This is a user's token
        user = api_key.user
        review = Review.create(
          lti_app_id: @lti_app.id,
          user_id: user.id,
          rating: params[:rating],
          comments: params[:comments]
        )

        if review.new_record?
          render json: { errors: review.errors.messages }, status: 422
        else
          render json: review, status: 201
        end
      end
    else
      render json: { error: 'Missing access token' }, status: 422
    end
  end

  # PATCH/PUT /reviews/1
  def update
    if @review.update(review_params)
      redirect_to @review, notice: 'Review was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private
    def load_lti_app
      @lti_app = LtiApp.where(short_name: params[:lti_app_id]).first
      unless @lti_app
        render json: {}, status: 404
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def review_params
      # params.require(:review).permit(:membership_id, :user_id, :rating, :comments, :lti_app_id)
    end
end
