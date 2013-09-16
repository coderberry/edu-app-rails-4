class CreateLtiAppsOrganizations < ActiveRecord::Migration
  def change
    create_table :lti_apps_organizations do |t|
      t.integer :lti_app_id, null: false
      t.integer :organization_id, null: false
      t.boolean :is_visible
    end
    add_index :lti_apps_organizations, [ :lti_app_id, :organization_id ], unique: true
  end
end
