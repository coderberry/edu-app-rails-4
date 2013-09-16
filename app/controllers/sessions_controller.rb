class SessionsController < ApplicationController

  def create
    if params[:provider]
      email = parse_email(env["omniauth.auth"], params[:provider])
      authentication = Authentication.from_omniauth(env["omniauth.auth"], email, current_user)

      if current_user.present?
        redirect_to authentications_path, notice: "Successfully linked account"
      else
        session[:user_id] = authentication.user.id
        redirect_to root_url, notice: "Logged in!"
      end
    else
      user = User.where(email: params[:email]).first
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to root_url, notice: "Logged in!"
      else
        flash.now.alert = "Email or password is invalid"
        render "new"
      end
    end
  end

  def oauth_failure
    session[:user_id] = nil
    redirect_to login_url, notice: "We were unable to authorize this account"
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, notice: "Signed out!"
  end

  def parse_email(auth, provider)
    case provider
    when "twitter"
      nil
    when "github"
      auth["info"]["email"]
    when "facebook"
      auth["info"]["email"]
    when "google_oauth2"
      auth["info"]["email"]
    end
  end
end
