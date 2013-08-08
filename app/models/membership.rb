class Membership < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :organization
  belongs_to :user
end
