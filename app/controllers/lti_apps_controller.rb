class LtiAppsController < ApplicationController
  before_action :set_lti_app, only: [:update, :destroy]

  # GET /lti_apps
  def index
    @lti_apps = LtiApp.inclusive.include_rating.include_total_ratings.order(:name).all
    respond_to do |format|
      format.html
      format.json { render json: @lti_apps }
    end
  end

  # GET /lti_apps/1
  def show
    @lti_app = LtiApp.inclusive.include_rating.include_total_ratings.where(short_name: params[:id]).first
    respond_to do |format|
      format.html
      format.xml  { render xml: @lti_app.cartridge.to_xml }
      format.json { render json: @lti_app }
    end
  end

  # GET /lti_apps/new
  def new
    @lti_app = LtiApp.new
  end

  # GET /lti_apps/1/edit
  def edit
    # Inject permission check here
    @lti_app = LtiApp.where(short_name: params[:id]).first
  end

  # POST /lti_apps
  def create
    @lti_app = LtiApp.new(lti_app_params)

    if @lti_app.save
      redirect_to @lti_app, notice: 'Lti app was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /lti_apps/1
  def update
    if @lti_app.update(lti_app_params)
      redirect_to lti_app_path(@lti_app.short_name), notice: 'Lti app was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /lti_apps/1
  def destroy
    @lti_app.destroy
    redirect_to lti_apps_url, notice: 'Lti app was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lti_app
      @lti_app = LtiApp.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def lti_app_params
      params.require(:lti_app).permit(:user_id, :short_name, :name, :description, :status, :testing_instructions, :support_url, :author_name, :is_public, :app_type, :ims_cert_url, :preview_url, :config_url, :data_url, :cartridge, :banner_image_url, :logo_image_url, :short_description)
    end
end
