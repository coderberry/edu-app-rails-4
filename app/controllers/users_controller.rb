class UsersController < ApplicationController
  before_filter :authorize, only: [:edit]
  layout :layout

  def new
    @user = User.new(is_registering: true)
  end

  def create
    @user = User.new(user_params.merge({ is_registering: true }))
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: "Welcome #{@user.name.split.first}!"
    else
      flash.now[:error] = @user.errors.full_messages.join(', ')
      render action: 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.name = params["user"]["name"]
    @user.url = params["user"]["url"]
    @user.avatar_url = params["user"]["avatar_url"]
    if @user.save
      redirect_to edit_profile_path, notice: 'Your profile has been updated successfully'
    else
      flash.now[:error] = "Invalid data"
      render action: 'edit'
    end
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    @user.force_require_password = true
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      redirect_to edit_password_path, notice: 'Your password has been changed successfully'
    else
      flash.now[:error] = "Please fix the errors below and try again"
      render action: 'edit_password'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def layout
    if ['new', 'create'].include? action_name
      "application"
    else
      "settings"
    end
  end
end
