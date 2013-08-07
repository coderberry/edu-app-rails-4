class Organization < ActiveRecord::Base
  # relationships .............................................................
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :api_keys, as: :tokenable

  # validations ...............................................................
  validates :name, presence: true

  # public instance methods ...................................................
  def regenerate_api_key
    api_keys.map(&:expire)
    api_keys.create
  end

  def current_api_key
    api_keys.active.first
  end
end
