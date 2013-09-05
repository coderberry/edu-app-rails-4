class Admin::MembershipsController < AdminController
  before_action :set_data

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
    @membership = Membership.find(params[:id])
    @redir = params[:redir] || "/admin/organizations/#{@membership.organization.id}"
  end

  # Only allow a trusted parameter "white list" through.
  def membership_params
    params.require(:membership).permit(:is_admin, :remote_uid)
  end
end
