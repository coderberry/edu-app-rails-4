class LtiAppConfigurationsController < ApplicationController
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
