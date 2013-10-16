class LtiAppSerializer < ActiveModel::Serializer
  attributes :id, :short_name, :name, :description, :short_description, :status, :is_public, :app_type,
             :preview_url, :banner_image_url, :logo_image_url, :icon_image_url, :average_rating, 
             :total_ratings, :is_certified, :config_xml_url, :requires_secret, :tags, :config_options

  has_many :tags

  def config_options
    opts = ActiveModel::ArraySerializer.new(object.config_options).as_json
    if object.lti_app_configuration
      object.lti_app_configuration.optional_launch_types.each do |type|
        opts << {
            name: type,
            param_type: "checkbox",
            description: "Show in #{type.titleize}",
            is_required: false,
            default_value: 0
        }
      end
    end
    opts
  end

  def short_description
    object.short_description.blank? ? truncate(object.description, 160) : object.short_description
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

  def truncate(str, length = 20)
    return str if str.blank?
    str.size > length+5 ? str[0,length] + "..." : str
  end

end