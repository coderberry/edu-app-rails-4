class Review < ActiveRecord::Base
  # relationships .............................................................
  # The user association is required because we need to limit the number of reviews to one per app.
  # The membership is optional and will only be populated if the review is added via the external API.
  belongs_to :membership
  belongs_to :user
  belongs_to :lti_app

  # validations ...............................................................
  validates :lti_app_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :lti_app_id, message: "has already submitted a review for this app" }
  validates :rating, presence: true, inclusion: { in: 1..5 }

  # scopes ....................................................................
  default_scope order('created_at DESC')
  scope :with_content, -> { where("comments IS NOT NULL").where("char_length(comments) > 0") }
end
