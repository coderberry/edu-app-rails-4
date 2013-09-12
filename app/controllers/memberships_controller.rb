class MembershipsController < ApplicationController
  before_action :set_data

  def new
  end

  def create
    target_user = User.where(email: params[:email]).first
    if target_user
      if @organization.memberships.map(&:user_id).include? target_user.id
        flash.now[:error] = "#{target_user.name} is already a member of this organization"
        render 'new'
      else
        @membership = @organization.memberships.new(membership_params)
        @membership.user_id = target_user.id
        if @membership.save
          redirect_to organization_path(@organization), notice: "Successfully added #{target_user.name} to the organization"
        else
          render 'new'
        end
      end
    else
      flash.now[:error] = "There is no user with that email address"
      render 'new'
    end
  end

  def edit
  end

  def update
    if @membership.update(membership_params)
      redirect_to @redir, notice: 'Membership was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  def set_data
    @organization = Organization.find(params[:organization_id])
    @membership = @organization.memberships.where(id: params[:id]).first_or_initialize
    @redir = params[:redir] || "/organizations/#{@membership.organization.id}"
  end

  # Only allow a trusted parameter "white list" through.
  def membership_params
    params.require(:membership).permit(:is_admin, :remote_uid)
  end
end
