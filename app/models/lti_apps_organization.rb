class LtiAppsOrganization < ActiveRecord::Base
  belongs_to :lti_app
  belongs_to :organization
end
