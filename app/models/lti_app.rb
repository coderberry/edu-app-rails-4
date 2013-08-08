class LtiApp < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :reviews, dependent: :destroy

  # validations ...............................................................
  validates :name, presence: true
  validates :short_name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: ["pending", "active", "disabled"] }

  # scopes ....................................................................
  scope :inclusive,             -> { select 'lti_apps.*' }
  scope :include_rating,        -> { select '(select avg("rating") FROM "reviews" where "reviews"."lti_app_id" = "lti_apps"."id") as "average_rating"' }
  scope :include_total_ratings, -> { select '(select count("id") FROM "reviews" where "reviews"."lti_app_id" = "lti_apps"."id") as "total_ratings"' }
end
