class LtiAppConfiguration < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user

  # validations ...............................................................
  validates :short_name, presence: true, uniqueness: true
  validates :user_id, presence: true

  # public instance methods ...................................................
  def title
    self.config['title']
  end
end
