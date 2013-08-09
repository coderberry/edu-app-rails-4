class Authentication < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user

  # scopes ....................................................................
  scope :twitter,       -> { where( provider: "twitter") }
  scope :facebook,      -> { where( provider: "facebook") }
  scope :github,        -> { where( provider: "github") }
  scope :google_oauth2, -> { where( provider: "google_oauth2") }

  # public instance methods ...................................................

  def image_url
    self.data['image_url'] || nil
  end

  def self.from_omniauth(omniauth, email=nil, user=nil)
    if auth = where(omniauth.slice("provider", "uid")).first
      user.merge(auth.user) if user && auth.user != user
      auth.user.update_attribute(:email, email) if email && auth.user.email == nil
      auth.update_attribute(:data,  omniauth['info'].to_json)
    else
      auth = create_from_omniauth(omniauth, email, user)
    end

    # dedupe twitter users from the old app
    if auth.provider == 'twitter' && old_user = User.where(twitter_nickname: omniauth["info"]["nickname"]).first
      auth.user.merge(old_user)
    end
    auth
  end

  def self.create_from_omniauth(omniauth, email=nil, user=nil)
    user ||= User.where(email: email).first if email
    user ||= User.create!(
      is_omniauthing: true,
      name: omniauth["info"]["name"],
      avatar_url: omniauth["info"]["image"],
      email: email
    )

    authentication = create!(
      provider: omniauth["provider"],
      uid: omniauth["uid"],
      data: omniauth["info"].to_json)

    user.authentications << authentication
    return authentication
  end
end
