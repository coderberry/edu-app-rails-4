class Membership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :reviews
end
