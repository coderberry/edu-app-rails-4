class Settings::OrganizationsController < ApplicationController
  before_filter :authorize
  layout "settings"

  def index
    @organizations = current_user.organizations.all
  end

  def show
    @organizations = current_user.organizations.find(params[:id])
  end

  def new
    @organization = current_user.organizations.build
  end

  def create
    @organization = user.organizations.create(organization_params)

    if @organization.save
      redirect_to [:settings, @organization], notice: 'Organization was successfully created'
    else
      render action: 'new'
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name)
  end
end
