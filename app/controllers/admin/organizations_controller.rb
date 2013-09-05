class Admin::OrganizationsController < AdminController
  before_action :set_organization, except: [:index]

  def index
    @organizations = Organization.page(params[:page]).order('name ASC')
  end

  def show
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to [:admin, @organization], notice: 'Organization was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def organization_params
    params.require(:organization).permit(:name)
  end
end
