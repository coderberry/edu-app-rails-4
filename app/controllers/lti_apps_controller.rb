class LtiAppsController < ApplicationController
  before_action :set_lti_app, only: [:update, :destroy]
  before_action :build_tag_list
  before_action :authorize, except: [:index, :show]

  # GET /lti_apps
  def index
    @lti_apps = LtiApp.inclusive.include_rating.include_total_ratings.include_tag_id_array.active.order(:name).load
    respond_to do |format|
      format.html
      format.json { render json: @lti_apps }
    end
  end

  # GET /lti_apps/1
  def show
    @lti_app = LtiApp.inclusive.include_rating.include_total_ratings.include_tag_id_array.where(short_name: params[:id]).first
    respond_to do |format|
      format.html
      format.xml  { render xml: @lti_app.cartridge.to_xml }
      format.json { render json: @lti_app }
    end
  end

  def my
    @active_tab = 'my_stuff'
    if current_user.is_admin?
      @lti_apps = LtiApp.inclusive.include_rating.include_total_ratings.order(:name)
    else
      @lti_apps = current_user.lti_apps.inclusive.include_rating.include_total_ratings.order(:name)
    end
    respond_to do |format|
      format.html
      format.json { render json: @lti_apps }
    end
  end

  def export_as_json
    @lti_apps = LtiApp.load
    render json: LtiApp.all.map(&:as_json)
  end

  # GET /lti_apps/new
  def new
    @active_tab = 'my_stuff'
    @lti_app = LtiApp.new
  end

  # GET /lti_apps/1/edit
  def edit
    @active_tab = 'my_stuff'
    # Inject permission check here
    @lti_app = LtiApp.where(short_name: params[:id]).first
  end

  # POST /lti_apps
  def create
    @lti_app = LtiApp.new(lti_app_params)
    @lti_app.user_id = current_user.id

    case params[:cartridge_source]
    when 'cartridge_id'
      lti_app_configuration = current_user.lti_app_configurations.where(id: params[:lti_app_configuration_id]).first
      if !lti_app_configuration
        flash.now[:error] = "You must select an app configuration"
      end
    when 'url'
      lti_app_configuration = current_user.lti_app_configurations.create_from_url(params[:config_url])
      if !lti_app_configuration
        flash.now[:error] = "Invalid XML from URL"
      end
    when 'xml'
      lti_app_configuration = current_user.lti_app_configurations.create_from_xml(params[:xml])
      if !lti_app_configuration
        flash.now[:error] = "Invalid XML"
      end
    else
      flash.now[:error] = "You must enter/select an App Configuration"
    end

    unless lti_app_configuration
      render action: 'new'
      return
    end

    @lti_app.lti_app_configuration = lti_app_configuration

    if @lti_app.save
      redirect_to lti_app_path(@lti_app.short_name), notice: 'LTI App was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /lti_apps/1
  def update
    if @lti_app.update(lti_app_params)
      redirect_to lti_app_path(@lti_app.short_name), notice: 'LTI App was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def deleted
    @active_tab = 'my_stuff'
    authorize_admin
    @lti_apps = LtiApp.with_deleted.inclusive.include_rating.include_total_ratings.where("deleted_at IS NOT NULL")
  end

  # DELETE /lti_apps/1
  def destroy
    msg = "LTI App was successfully deleted. [UNDO](#{restore_lti_app_path(@lti_app.short_name)})"
    @lti_app.destroy
    redirect_to root_url, notice: msg
  end

  def restore
    @lti_app = LtiApp.with_deleted.where(short_name: params[:id]).first
    @lti_app.update_attribute(:deleted_at, nil)
    redirect_to lti_app_path(@lti_app.short_name), notice: 'LTI App was successfully restored.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lti_app
      @lti_app = LtiApp.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def lti_app_params
      params.require(:lti_app).permit(
        :user_id, :short_name, :name, :description, :status, :testing_instructions, :support_url, 
        :author_name, :is_public, :app_type, :ims_cert_url, :preview_url, :config_url, :data_url, 
        :lti_app_configuration_id, :banner_image_url, :logo_image_url, :short_description, :organization_id)
    end

    def build_tag_list
      @tags = {}
      Tag.all.each do |tag|
        @tags[tag.id] = tag
      end
    end
end
