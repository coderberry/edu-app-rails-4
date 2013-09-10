class LtiAppConfigurationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    user = current_user
    user ||= User.with_access_token(params[:token]) if params[:token].present?
    if user
      render json: user.lti_app_configurations
    else
      render json: { lti_app_configurations: [] }
    end
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

  def import
    lti_app_configuration = LtiAppConfiguration.create_from_url(current_user.id, params[:url])
    if lti_app_configuration
      if !lti_app_configuration.new_record?
        render json: lti_app_configuration, status: 201
      else
        render json: { errors: lti_app_configuration.errors }, status: 422
      end
    else
      head 500
    end
  end

  def create_from_xml
    lti_app_configuration = LtiAppConfiguration.create_from_xml(current_user.id, params[:xml])
    if lti_app_configuration
      if !lti_app_configuration.new_record?
        render json: lti_app_configuration, status: 201
      else
        render json: { errors: lti_app_configuration.errors }, status: 422
      end
    else
      head 500
    end
  end

  def update
    config = JSON.parse(params[:config])
    lti_app_configuration = current_user.lti_app_configurations.where(uid: params[:uid]).first
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
    lti_app_configuration = current_user.lti_app_configurations.where(uid: uid).first
    if lti_app_configuration
      lti_app_configuration.destroy
      head 200
    else
      head 404
    end
  end

  def xml
    lti_app_configuration = LtiAppConfiguration.where(uid: params[:uid]).first
    if lti_app_configuration
      begin
        params.delete(:controller)
        params.delete(:action)
        tool_config = lti_app_configuration.tool_config(params)
        render xml: tool_config.to_xml
      rescue EA::MissingConfigOptionsError => err
        render xml: err.errors.map { |k,v| "#{k} #{v}" }, root: :errors
      end
    else
      head 404
    end
  end
end
