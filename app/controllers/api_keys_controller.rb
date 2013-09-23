class ApiKeysController < ApplicationController
  before_filter :authorize
  before_action :set_organization

  def index
    @api_keys = @organization.api_keys
  end

  def create_token
    @organization.api_keys.create
    redirect_to organization_api_keys_path(@organization), notice: "Created App Center Token successfully"
  end

  def renew_token
    @token = @organization.api_keys.find(params[:id])
    @token.renew
    redirect_to organization_api_keys_path(@organization), notice: "Renewed App Center Token successfully"
  end

  def expire_token
    @token = @organization.api_keys.find(params[:id])
    @token.expire
    redirect_to organization_api_keys_path(@organization), notice: "Expired App Center Token successfully"
  end

  private

  def set_organization
    if current_user.is_admin?
      @organization = Organization.find(params[:organization_id])
    else
      @organization = current_user.organizations.find(params[:organization_id])
    end
  end

  # Only allow a trusted parameter "white list" through.
  def membership_params
    params.require(:membership).permit(:is_admin, :remote_uid)
  end
end
