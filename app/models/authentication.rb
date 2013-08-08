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

  def self.from_omniauth(auth, email=nil, user=nil)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth, email, user)
  end

  def self.create_from_omniauth(auth, email=nil, user=nil)
    user ||= User.where(email: email).first_or_create!(
      is_omniauthing: true,
      name: auth["info"]["name"],
      avatar_url: auth["info"]["image"])

    authentication = create!(
      provider: auth["provider"],
      uid: auth["uid"],
      data: auth["info"].to_json)

    user.authentications << authentication
    return authentication
  end
end
