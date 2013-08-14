class AddOrganizationIdToLtiApps < ActiveRecord::Migration
  def change
    add_column :lti_apps, :organization_id, :integer
    add_index :lti_apps, :organization_id
  end
end
