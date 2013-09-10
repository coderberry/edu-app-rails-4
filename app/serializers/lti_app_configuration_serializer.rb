class LtiAppConfigurationSerializer < ActiveModel::Serializer
  attributes :uid, :user_id, :lti_app_id, :config, :name, :icon, :created_at, :updated_at

  def lti_app_id
    object.lti_app.try(:id)
  end

  def config
    object.config.try(:to_json)
  end

  def name
    object.config['title']
  end

  def icon
    object.config['icon_url']
  end
end