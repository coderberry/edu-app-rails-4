require 'digest/md5'

class User < ActiveRecord::Base
  # relationships .............................................................
  has_many :authentications, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :api_keys, as: :tokenable

  # security (i.e. attr_accessible) ...........................................
  attr_accessor :is_registering, :is_omniauthing, :force_require_email, :force_require_password

  # validations ...............................................................
  validates :email, 
              uniqueness: { if: :require_email? }, 
              format: { with: /.+@.+\..+/, if: :require_email? }, 
              presence: { if: :require_email? }

  validates :name, 
              presence: true

  validates :password, 
              presence: { on: :create, if: :require_password? }, 
              confirmation: { if: :require_password? }, 
              length: { minimum: 6, if: :require_password? }

  # additional config .........................................................
  has_secure_password :validations => false

  # public instance methods ...................................................
  def session_api_key
    api_keys.create
  end

  def clear_expired_api_keys
    api_keys.expired.destroy_all
  end

  def profile_image_url
    @profile_image_url ||= self.avatar_url
    @profile_image_url ||= self.authentications.first.try(:image_url)
    @profile_image_url ||= self.gravatar_url
    @profile_image_url
  end

  def social_links
    ret = {}
    self.authentications.each do |auth|
      case auth.provider
        when "twitter"
          ret[:twitter] = { icon: "icon-twitter-sign", url: auth.data["urls"]["Twitter"] }
        when "facebook"
          ret[:facebook] = { icon: "icon-facebook-sign", url: auth.data["urls"]["Facebook"] }
        when "github"
          ret[:github] = { icon: "icon-github", url: auth.data["urls"]["GitHub"] }
        when "google_oauth2"
          ret[:google_oauth2] = { icon: "icon-google-plus-sign", url: auth.data["urls"]["Google"] }
      end
    end
    ret
  end

  def gravatar_url(options = {})
    options[:gravatar_id] = Digest::MD5.hexdigest(self.email)
    return "http://www.gravatar.com/avatar.php?" + options.to_param
  end

  # private instance methods ..................................................
  private

  def require_email?
    if !!self.is_registering # Standard authentication
      true
    elsif !!self.force_require_email
      true
    elsif !!self.is_omniauthing # Authenticating via Omniauth
      false
    else # Authenticating via Reviews
      true
    end
  end

  def require_password?
    if !!self.is_registering # Standard authentication
      true
    elsif !!self.force_require_password
      true
    elsif !!self.is_omniauthing # Authenticating via Omniauth
      false
    else # Authenticating via Reviews
      false
    end
  end
end
