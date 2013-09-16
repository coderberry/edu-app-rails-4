###
# Note: This could be optimized into a view if we want to in the future
#
# SELECT lti_apps.*, 
#       (select avg("rating") FROM "reviews" where "reviews"."lti_app_id" = "lti_apps"."id") as average_rating,
#       (select count("id") FROM "reviews" where "reviews"."lti_app_id" = "lti_apps"."id") as "total_ratings",
#       (select array(select tag_id from lti_apps_tags where lti_apps_tags.lti_app_id = lti_apps.id)) as "tag_ids"
# FROM lti_apps
###

class LtiApp < ActiveRecord::Base
  acts_as_paranoid
  
  # relationships .............................................................
  belongs_to :user
  belongs_to :organization
  belongs_to :cartridge
  belongs_to :lti_app_configuration
  has_and_belongs_to_many :tags
  has_many :reviews, dependent: :destroy
  has_many :lti_apps_organizations

  # validations ...............................................................
  validates :name, presence: true
  validates :short_name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z_0-9]+\Z/, message: "is not valid. Only letters and underscores" }
  validates :status, presence: true, inclusion: { in: ["pending", "active", "disabled"] }

  # scopes ....................................................................
  scope :inclusive,             -> { select 'lti_apps.*' }
  scope :include_rating,        -> { select '(select avg("rating") FROM "reviews" where "reviews"."lti_app_id" = "lti_apps"."id") as "average_rating"' }
  scope :include_total_ratings, -> { select '(select count("id") FROM "reviews" where "reviews"."lti_app_id" = "lti_apps"."id") as "total_ratings"' }
  scope :include_tag_id_array,  -> { select '(select array(select "tag_id" from "lti_apps_tags" where "lti_apps_tags"."lti_app_id" = "lti_apps"."id")) as "tag_ids"'}
  scope :active,                -> { where(status: 'active') }
  scope :pending,               -> { where(status: 'pending') }
  scope :public,                -> { where(is_public: true) }

  def icon_url
    lti_app_configuration.try(:icon_url)
  end

  def visible_for?(organization)
    is_visible = lti_apps_organizations.where(organization_id: organization.id).first.try(:is_visible)
    is_visible ||= organization.is_list_apps_without_approval?
  end

  def active?
    self.status == 'active'
  end

end
