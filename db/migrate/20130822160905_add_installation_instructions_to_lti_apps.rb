class AddInstallationInstructionsToLtiApps < ActiveRecord::Migration
  def change
    add_column :lti_apps, :installation_instructions, :text
  end
end
