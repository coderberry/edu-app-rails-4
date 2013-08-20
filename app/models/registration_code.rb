class RegistrationCode < ActiveRecord::Base
  # relationships .............................................................
  # The user association is required because we need to limit the number of reviews to one per app.
  # The membership is optional and will only be populated if the review is added via the external API.
  belongs_to :user

  # validations ...............................................................
  validates :user_id, presence: true
  validates :email, presence: true

  before_create :generate_code
  before_create :set_valid_until

  scope :active, -> { where("valid_until >= ?", Time.now) }

  def generate_code
    self.code = SecureRandom.uuid
  end

  def set_valid_until
    self.valid_until = 1.day.from_now
  end
end
