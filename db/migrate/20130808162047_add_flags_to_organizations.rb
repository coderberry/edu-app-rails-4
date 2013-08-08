class AddFlagsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_list_anonymous_only, :boolean, default: false
    add_column :organizations, :is_list_apps_without_approval, :boolean, default: false
    add_column :organizations, :url, :string, limit: 1000
  end
end
