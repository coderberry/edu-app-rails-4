class LtiAppSerializer < ActiveModel::Serializer
  attributes :id, :short_name, :name, :short_description, :status, :is_public, :app_type, 
             :preview_url, :banner_image_url, :logo_image_url, :icon_image_url, :average_rating, 
             :total_ratings, :is_certified

  def short_description
    object.short_description ? object.short_description : trancate(object.description, 80)
  end

  def average_rating
    object.average_rating.try(:to_f) || 0
  end

  def is_certified
    object.ims_cert_url.present?
  end

  private

  def trancate(str, length = 20)
    return str if str.blank?
    str.size > length+5 ? str[0,length] + "..." : str
  end

end