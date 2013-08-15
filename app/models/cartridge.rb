class Cartridge < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user

  # callbacks .................................................................
  before_create :generate_uid

  # validations ...............................................................
  validates :name, presence: true

  # private instance methods ..................................................
  private

  def generate_uid
    begin
      len = 16
      self.uid = rand(36**len).to_s(36)
    end while self.class.exists?(uid: uid)
  end
  
end
