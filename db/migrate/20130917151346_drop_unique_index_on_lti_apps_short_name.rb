class DropUniqueIndexOnLtiAppsShortName < ActiveRecord::Migration
  def change
    remove_index :lti_apps, :short_name
    add_index :lti_apps, :short_name, unique: false
  end
end
