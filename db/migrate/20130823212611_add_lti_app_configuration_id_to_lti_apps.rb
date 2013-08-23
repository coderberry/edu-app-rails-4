class AddLtiAppConfigurationIdToLtiApps < ActiveRecord::Migration
  def change
    add_column :lti_apps, :lti_app_configuration_id, :integer
    add_index :lti_apps, :lti_app_configuration_id
  end
end
