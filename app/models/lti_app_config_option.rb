class LtiAppConfigOption < ActiveRecord::Base
  belongs_to :lti_app
  default_scope { order('param_type DESC, name') }
end
