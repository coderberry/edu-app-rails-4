class Admin::UsersController < AdminController
  before_action :set_user, except: [:index]

  def index
    @users = User.page(params[:page]).order('name ASC')
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to [:admin, @user], notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:name, :email, :avatar_url, :url, :is_admin)
  end
end
