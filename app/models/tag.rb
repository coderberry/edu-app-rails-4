class Tag < ActiveRecord::Base
  # relationships .............................................................
  has_and_belongs_to_many :lti_apps

  # scopes ....................................................................
  scope :extensions,        -> { where(:context => 'extension') }
  scope :categories,        -> { where(:context => 'category') }
  scope :education_levels,  -> { where(:context => 'education_level') }
  scope :privacy_levels,    -> { where(:context => 'privacy_level') }
  scope :app_types,         -> { where(:context => 'app_type') }
end
