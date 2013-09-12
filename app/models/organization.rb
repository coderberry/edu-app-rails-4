class Organization < ActiveRecord::Base
  # relationships .............................................................
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :api_keys, as: :tokenable
  has_many :lti_apps

  # validations ...............................................................
  validates :name, presence: true

  # public instance methods ...................................................
  def regenerate_api_key
    api_keys.map(&:expire)
    api_keys.create
  end

  def current_api_key
    api_keys.active.first || api_keys.create
  end

  def details
    attributes.symbolize_keys!.slice(
      :name, :created_at, :updated_at
    )
  end

  def add_admin(user)
    member = memberships.where(user_id: user.id).first_or_create
    member.is_admin = true
    member.save
  end
end
