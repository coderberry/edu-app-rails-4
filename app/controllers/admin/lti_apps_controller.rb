class Admin::LtiAppsController < AdminController
  def index
    @lti_apps = LtiApp.page(params[:page]).order('name ASC')
  end
end
