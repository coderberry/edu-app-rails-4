class Settings::MembershipsController < ApplicationController
  before_filter :authorize
  layout "settings"

  def index
    @memberships = current_user.memberships.all
  end

  def show
    @membership = current_user.memberships.find(params[:id])
  end

  def new
    @organization = current_user.organizations.build
  end

  def create
    @organization = current_user.organizations.create(organization_params)

    if @organization.save
      membership = current_user.memberships.where(organization_id: @organization.id).first
      membership.update_attribute(:is_admin, true) if membership.present?
      redirect_to settings_membership_path(membership), notice: 'Organization was successfully created'
    else
      flash.now[:error] = "Please fix the errors below and try again"
      render action: 'new'
    end
  end

  def reset_api_token
    @membership = current_user.memberships.find(params[:id])
    if @membership.is_admin?
      @membership.organization.regenerate_api_key
      redirect_to settings_membership_path(@membership), notice: 'Organization was successfully created'
    else
      redirect_to settings_membership_path(@membership), error: "You do not have permissions to do this"
    end
  end

  def remove_member_from_organization
    @membership = current_user.memberships.find(params[:id])
    organization = @membership.organization
    target_membership = organization.memberships.find(params[:target_id])
    if target_membership
      member_name = target_membership.user.name
      target_membership.destroy
      redirect_to settings_membership_path(@membership), notice: "Successfully removed #{member_name} from the organization"
    else
      redirect_to settings_membership_path(@membership), error: "Unable to remove member"
    end
  end

  def add_member_to_organization
    @membership = current_user.memberships.find(params[:id])
    role = params[:role]
    target_user = User.where(email: params[:email]).first
    if target_user
      if @membership.organization.memberships.map(&:user_id).include? target_user.id
        redirect_to settings_membership_path(@membership), alert: "#{target_user.name} is already a member of this organization"
      else
        new_membership = Membership.new(
          user_id: target_user.id,
          organization_id: @membership.organization.id,
          is_admin: params[:role] == 'administrator')
        if new_membership.save
          redirect_to settings_membership_path(@membership), notice: "Successfully added #{target_user.name} to the organization"
        else
          redirect_to settings_membership_path(@membership), error: "We were unable to add this person"
        end
      end
    else
      redirect_to settings_membership_path(@membership), alert: "There is no user with that email address"
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :is_list_anonymous_only, :is_list_apps_without_approval, :url)
  end
end
