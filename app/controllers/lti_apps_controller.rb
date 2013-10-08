class LtiAppsController < ApplicationController
  before_action :set_lti_app, only: [:update, :destroy]
  before_action :build_tag_list
  before_action :authorize, except: [:index, :show]

  # GET /lti_apps
  def index
    @lti_apps = LtiApp.inclusive.include_rating.include_total_ratings.include_tag_id_array.active.order(:name).load.map(&:limited)
    @ng_app = "app"
    @active_tab = 'apps'
    @env = {
      apps: @lti_apps,
      categories: Tag.categories.map {|c| { id: c.id, name: c.name }},
      education_levels: Tag.education_levels.map {|c| { id: c.id, name: c.name }},
      platforms: Tag.platforms.map {|c| { id: c.id, name: c.name }}
    }
    
    respond_to do |format|
      format.html { render layout: 'clean' }
      format.json { render json: @lti_apps }
    end
  end

  # GET /lti_apps/1
  def show
    @active_tab = 'apps'
    @lti_app = LtiApp.inclusive.include_rating.include_total_ratings.include_tag_id_array.where(short_name: params[:id]).first
    @ng_app = "app"
    config_options = []
    optional_launch_types = []
    if @lti_app.lti_app_configuration.present?
      @lti_app.lti_app_configuration.config_options.each do |co|
        co['is_checked'] = false
        config_options << co
      end
      @lti_app.lti_app_configuration.optional_launch_types.each do |olt|
        optional_launch_types << { name: olt, is_checked: false }
      end
    end

    @lti_app.lti_app_config_options.each do |laco|
      config_options << {
        name: laco.name,
        description: laco.description,
        type: laco.param_type,
        default_value: laco.default_value,
        is_required: laco.is_required,
        is_checked: false
      }
    end

    url = if @lti_app.lti_app_configuration.present? 
            lti_app_configuration_xml_url(@lti_app.lti_app_configuration.try(:uid))
          else
            @lti_app.config_xml_url
          end
    @configurator_data = {
      config_options: config_options,
      optional_launch_types: optional_launch_types,
      config_url_base: url
    }
    respond_to do |format|
      format.html
      format.xml  { render xml: @lti_app.cartridge.to_xml }
      format.json { render json: @lti_app }
    end
  end

  def my
    @active_tab = 'my_stuff'
    @q = params[:q] || {}
    if current_user.is_admin?
      @search = LtiApp.inclusive.include_rating.include_total_ratings.search(@q)
    else
      @search = current_user.lti_apps.inclusive.include_rating.include_total_ratings.search(@q)
    end
    @search.sorts = 'name asc' if @search.sorts.empty?
    @lti_apps = @search.result(distinct: true).paginate(page: params[:page])
  end

  def export_as_json
    @lti_apps = LtiApp.load
    render json: LtiApp.all.map(&:as_json)
  end

  # GET /lti_apps/new
  def new
    @active_tab = 'submit'
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
    when 'external'
      lti_app_configuration = nil
      @lti_app.valid?
    else
      flash.now[:error] = "You must enter/select an App Configuration"
    end

    if @lti_app.config_xml_url.blank? && lti_app_configuration.blank?
      render action: 'new'
      return
    end

    @lti_app.lti_app_configuration = lti_app_configuration

    if @lti_app.save
      @lti_app.tag_ids = params[:tag_ids]
      redirect_to lti_app_path(@lti_app.short_name), notice: 'LTI App was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /lti_apps/1
  def update
    if @lti_app.update(lti_app_params)
      @lti_app.tag_ids = params[:tag_ids]
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
        :user_id, :short_name, :name, :description, :status, :installation_instructions, :testing_instructions, :support_url, :config_xml_url,
        :author_name, :is_public, :app_type, :ims_cert_url, :preview_url, :config_url, :data_url, 
        :lti_app_configuration_id, :banner_image_url, :logo_image_url, :short_description, :organization_id, 
        lti_app_config_options_attributes: [:id, :name, :param_type, :default_value, :description, :is_required, :_destroy] )
    end

    def build_tag_list
      @tags = {}
      Tag.all.each do |tag|
        @tags[tag.id] = tag
      end
    end
end
