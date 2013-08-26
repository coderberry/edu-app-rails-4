class LtiAppConfigurationSerializer < ActiveModel::Serializer
  attributes :uid, :user_id, :lti_app_id, :config, :created_at, :updated_at

  def lti_app_id
    object.lti_app.id
  end
end