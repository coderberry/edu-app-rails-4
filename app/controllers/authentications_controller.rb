class AuthenticationsController < ApplicationController
  before_filter :authorize

  def index
    @active_tab = 'my_stuff'
    @authentications = {
      twitter: { name: "Twitter", class_name: "icon-twitter",
        authentication: current_user.authentications.twitter.first },
      facebook: { name: "Facebook", class_name: "icon-facebook-sign",
        authentication: current_user.authentications.facebook.first },
      github: { name: "GitHub", class_name: "icon-github",
        authentication: current_user.authentications.github.first },
      google_oauth2: { name: "Google", class_name: "icon-google-plus-sign",
        authentication: current_user.authentications.google_oauth2.first }
    }
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if @authentication
      @authentication.destroy
      redirect_to authentications_path, notice: "Successfully unlinked account"
    else
      redirect_to authentications_path
    end
  end
end
