class UsersController < ApplicationController
  before_filter :authorize, only: [:edit]
  before_filter :authorize_admin, only: [:index, :show]

  def index
    @active_tab = 'admin'
    @users = User.page(params[:page]).order('name ASC')
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new(is_registering: true)
  end

  def create
    @user = User.new(user_params.merge({ is_registering: true, force_require_email: true }))
    if @user.valid?
      #save the user
      email = @user.email
      @user.attributes = {email: nil, force_require_email: false}
      @user.save!

      #generate an an email address confirmation email
      generate_registration_code(@user, email)

      #set the users session and log them in
      login_user(@user)
      redirect_to root_url, notice: "Welcome #{@user.name.split.first}!"
    else
      flash.now[:error] = "Please fix the errors below and try again"
      render action: 'new'
    end
  end

  def edit
    @active_tab = 'my_stuff'
    if params[:id].present? && current_user.is_admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    if code = @user.registration_codes.active.last
      @user.email = code.email
      @confirmation_required = true
    end
  end

  def update
    if params[:id].present? && current_user.is_admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end

    if params["user"]["code"] && !params["user"]["code"].empty?
      if user = update_email_from_code(params["user"]["code"])
        login_user(@user = user)
      else
        flash.now[:error] = "Invalid confirmation code"
        @user.email = @user.registration_codes.active.last.email
        @confirmation_required = true
        @code = params["user"]["code"]
        @user.errors[:code] << "not recognized"
        return render action: 'edit'
      end
    end

    if @user.update_attributes(params.require(:user).permit(:name, :url, :avatar_url))
      if @user.email == params["user"]["email"]
        @user.registration_codes.clear
      elsif !params["user"]["email"].to_s.empty?
        @user.registration_codes.clear
        generate_registration_code(@user, params["user"]["email"])
        return redirect_to edit_profile_path, alert: 'An email has been sent to you new address for confirmation'
      end

      if current_user.is_admin?
        redirect_to edit_user_path(@user), notice: 'User account was updated successfully'
      else
        redirect_to edit_profile_path, notice: 'Your profile has been updated successfully'
      end
    else
      flash.now[:error] = "Invalid data"
      render action: 'edit'
    end
  end

  def update_email
    if @user = update_email_from_code(params["code"])
      login_user(@user)
      redirect_to edit_profile_path, notice: "Your email has bee updated successfully!"
    end
  end

  def edit_password
    @active_tab = 'my_stuff'
    if params[:id].present? && current_user.is_admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  def update_password
    @active_tab = 'my_stuff'
    if params[:id].present? && current_user.is_admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    @user.force_require_password = true
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      if current_user.is_admin?
        redirect_to edit_user_path(@user), notice: 'User account was updated successfully'
      else
        redirect_to edit_password_path, notice: 'Your password has been changed successfully'
      end
      
    else
      flash.now[:error] = "Please fix the errors below and try again"
      render action: 'edit_password'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Generates a registration code and sends the user an email
  def generate_registration_code(user, email)
    code = RegistrationCode.new(email: email)
    @user.registration_codes << code
    UserMailer.email_confirmation(code, url_for(:email_confirmation)).deliver
    code
  end

  # Updates a user's email and merges all accounts with the same email. Returns
  # the updated user
  def update_email_from_code(code)
    if registration_code = RegistrationCode.where(code: code).active.first
      if old_user = User.where(email: registration_code.email).first
        registration_code.user.merge(old_user)
      end
      registration_code.user.update_attributes(email: registration_code.email)
      registration_code.user.registration_codes.clear
      return registration_code.user
    end

    return false
  end
end
