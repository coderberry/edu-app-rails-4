class Admin::OrganizationsController < ApplicationController
  before_filter :authorize_admin

  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find(params[:id])
  end
end
