class LtiAppConfigurationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    render json: LtiAppConfiguration.order('updated_at desc').limit(5)
    # user = current_user
    # user ||= User.with_access_token(params[:token]) if params[:token].present?
    # if user
    #   render json: user.lti_app_configurations
    # else
    #   render json: { lti_app_configurations: [] }
    # end
  end

  def show
    if params[:uid] == 'new'
      render json: {}, status: 200
    else
      lti_app_configuration = LtiAppConfiguration.where(uid: params[:uid]).first
      if lti_app_configuration
        render json: lti_app_configuration
      else
        render json: {}, status: 404
      end
    end
  end

  def create
    config = JSON.parse(params[:config])
    lti_app_configuration = current_user.lti_app_configurations.build({
      config: config
    })
    if lti_app_configuration.save
      render json: lti_app_configuration, status: 201
    else
      render json: { errors: lti_app_configuration.errors }, status: 422
    end
  end

  def update
    config = JSON.parse(params[:config])
    lti_app_configuration = LtiAppConfiguration.where(uid: params[:uid]).first
    # lti_app_configuration = current_user.lti_app_configurations.where(uid: params[:uid]).first
    if lti_app_configuration
      lti_app_configuration.config = config
      if lti_app_configuration.save
        render json: lti_app_configuration, status: 200
      else
        render json: { errors: lti_app_configuration.errors }, status: 422
      end
    else
      render json: {}, status: 404
    end
  end

  def destroy
    uid = params[:lti_app_configuration][:uid]
    lti_app_configuration = LtiAppConfiguration.where(uid: uid).first
    # cartridge = current_user.cartridges.where(uid: uid).first
    if lti_app_configuration
      lti_app_configuration.destroy
      head 200
    else
      head 404
    end
  end

  def dump
    render json: LtiAppConfiguration.all
  end

  def json_to_xml
    data = params[:data]
    
    tc = IMS::LTI::ToolConfig.new
    tc.title = data['title']
    tc.description = data['description']
    tc.launch_url = data['launch_url']
    tc.icon = data['icon_url']

    data['extensions'].each do |k, ext|
      #...
    end
    render xml: tc.to_xml
  end

  def xml
    lti_app_configuration = LtiAppConfiguration.where(uid: params[:uid]).first
    if lti_app_configuration
      tool_config = lti_app_configuration.tool_config

      # remove optional extensions that aren't requested
      cartridge.extensions.each do |k,v|
        if !params[k] && v["optional"] == "true"
          tool_config.get_ext_params("canvas.instructure.com").delete(k)
        end
      end

      cartridge.custom_params.each do |k,v|
        if params[k]
          tool_config.set_custom_param(k, params[k])
        elsif v["required"] == "true"
          return render text: "#{k} is a required field"
        end
      end

      render xml: tool_config.to_xml
    else
      head 404
    end
  end
end
