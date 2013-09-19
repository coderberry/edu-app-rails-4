class ApiKey < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :tokenable, polymorphic: true

  # callbacks .................................................................
  before_create :generate_access_token, :set_expiry_date

  # scopes ....................................................................
  scope :active,  -> { where("expired_at >= ?", Time.now) }
  scope :expired, -> { where("expired_at < ?", Time.now) }

  def user
    tokenable.is_a?(User) ? tokenable : nil 
  end

  def organization
    tokenable.is_a?(Organization) ? tokenable : nil 
  end

  def expired?
    expired_at < Time.now
  end

  def expire
    unless self.expired_at < Time.now
      update_attribute(:expired_at, Time.now)
    end
  end

  def renew
    update_attribute(:expired_at, 1.year.from_now)
  end

  # protected instance methods ................................................
  # private instance methods ..................................................

  private

  def set_expiry_date
    self.expired_at = 1.year.from_now
  end

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
