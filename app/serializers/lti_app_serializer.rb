class LtiAppSerializer < ActiveModel::Serializer
  attributes :id, :short_name, :name, :short_description, :status, :is_public, :app_type, 
             :preview_url, :banner_image_url, :logo_image_url, :icon_image_url, :average_rating, 
             :total_ratings, :is_certified, :config_xml_url, :requires_secret, :tags

  has_many :tags

  def short_description
    object.short_description ? object.short_description : trancate(object.description, 80)
  end

  def average_rating
    object.average_rating.try(:to_f) || 0
  end

  def is_certified
    object.ims_cert_url.present?
  end

  def config_xml_url
    return object.config_xml_url if object.config_xml_url

    lti_app_configuration_xml_url(object.lti_app_configuration.uid)
  end

  private

  def trancate(str, length = 20)
    return str if str.blank?
    str.size > length+5 ? str[0,length] + "..." : str
  end

end