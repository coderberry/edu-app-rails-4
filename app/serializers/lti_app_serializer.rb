class LtiAppSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :short_name, :name, :short_description, :description, :status, 
             :testing_instructions, :support_url, :author_name, :is_public, :app_type, 
             :ims_cert_url, :preview_url, :config_url, :data_url, :banner_image_url, 
             :logo_image_url, :icon_image_url

  def short_description
    object.short_description ? object.short_description : trancate(object.description, 80)
  end

  private

  def trancate(string, length = 20)
    string.size > length+5 ? string[0,length] + "..." : string
  end

end