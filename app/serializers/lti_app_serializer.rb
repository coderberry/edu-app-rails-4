class LtiAppSerializer < ActiveModel::Serializer
  # attributes :id, :user_id, :short_name, :name, :short_description, :description, :status, 
  #            :testing_instructions, :support_url, :author_name, :is_public, :app_type, 
  #            :ims_cert_url, :preview_url, :config_url, :data_url, :banner_image_url, 
  #            :logo_image_url, :icon_image_url, :average_rating, :total_ratings
  attributes :id, :short_name, :name, :short_description, :status, :is_public, :app_type, 
             :preview_url, :banner_image_url, :logo_image_url, :icon_image_url, :average_rating, 
             :total_ratings

  def short_description
    object.short_description ? object.short_description : trancate(object.description, 80)
  end

  def average_rating
    object.average_rating.try(:to_f) || 0
  end

  private

  def trancate(string, length = 20)
    string.size > length+5 ? string[0,length] + "..." : string
  end

end