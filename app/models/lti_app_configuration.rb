class LtiAppConfiguration < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user
  has_one :lti_app

  # callbacks .................................................................
  before_create :generate_uid

  # validations ...............................................................
  validates :user_id, presence: true

  # public instance methods ...................................................
  def title
    self.config['title']
  end

  # private instance methods ..................................................
  private

  def generate_uid
    begin
      len = 16
      self.uid = rand(36**len).to_s(36)
    end while self.class.exists?(uid: uid)
  end
end
