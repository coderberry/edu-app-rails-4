require 'digest/md5'

class User < ActiveRecord::Base
  # relationships .............................................................
  has_many :authentications, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :api_keys, as: :tokenable
  has_many :reviews, dependent: :destroy
  has_many :lti_apps
  has_many :lti_app_configurations
  has_many :cartridges, dependent: :destroy
  has_many :registration_codes, dependent: :destroy

  # security (i.e. attr_accessible) ...........................................
  attr_accessor :is_registering, :is_omniauthing, :force_require_email,
                :force_require_password, :password_confirmation

  # validations ...............................................................
  validates :email,
              uniqueness: true,
              presence: true,
              format: { with: /.+@.+\..+/ },
              if: :require_email?

  validates :name,
              presence: true

  validates :password,
              presence: true,
              confirmation: true,
              length: {minimum: 6},
              if: :require_password?

  validates :password_confirmation,
              presence: true,
              if: :require_password?

  # additional config .........................................................
  has_secure_password :validations => false

  # class methods .............................................................
  def self.with_access_token(token)
    api_key = ApiKey.where(access_token: token).first
    api_key.try(:user)
  end

  # public instance methods ...................................................
  def current_api_key
    api_keys.active.first || api_keys.create
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
      begin
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
      rescue => ex
      end
    end
    ret
  end

  def gravatar_url(options = {})
    if self.email.present?
      options[:gravatar_id] = Digest::MD5.hexdigest(self.email)
      return "http://www.gravatar.com/avatar.php?" + options.to_param
    else
      return "http://www.gravatar.com/avatar.php"
    end
  end

  def can_manage?(organization)
    !!memberships.where(organization_id: organization.id).where(is_admin: true).exists?
  end

  def is_member?(organization)
    !!memberships.where(organization_id: organization.id).exists?
  end

  def can_edit?(lti_app)
    return true if lti_app.user_id == self.id
    return true if self.is_admin?
    return false unless lti_app.organization_id
    return can_manage?(lti_app.organization)
  end

  def as_tiny_json
    {
      name: self.name,
      url: self.url,
      avatar_url: self.profile_image_url
    }
  end

  def merge(user)
    keys = []
    self.as_json.each_pair{|k,v| keys << k if v == nil}
    keys.delete('twitter_nickname')
    self.update_attributes(user.as_json.slice(*keys)) if keys.count > 0

    user.memberships.each do |m|
      membership = self.memberships.find{|membership| m.organization == membership.organization}
      if membership && !membership.is_admin && m.is_admin
        membership.destroy!
        m.update_attribute(:user, self)
      elsif !membership
        m.update_attribute(:user, self)
      end
    end

    reviews = {}
    self.reviews.each{|r| reviews[r.lti_app_id] = r}
    user.reviews.each do |r|
      if !reviews[r.lti_app_id] || reviews[r.lti_app_id].updated_at < r.updated_at
        reviews[r.lti_app_id].destroy! if reviews[r.lti_app_id]
        self.reviews << r
      end
    end

    auths = {}
    self.authentications.each{|a| auths[a.provider] = a}
    user.authentications.each do |a|
      self.authentications << a if !auths[a.provider]
    end

    user.reload
    user.destroy!
  end

  def details
    attributes.symbolize_keys!.slice(
      :name, :email, :avatar_url, :url, :twitter_nickname, :is_admin, :created_at, :updated_at
    )
  end

  # private instance methods ..................................................
  private

  def require_email?
    !!self.force_require_email || !!self.email
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
