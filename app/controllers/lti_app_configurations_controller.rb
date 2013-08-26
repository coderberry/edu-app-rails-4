class LtiAppConfigurationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    render json: LtiAppConfiguration.limit(5)
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
end
