class AddCartridgeIdToLtiApps < ActiveRecord::Migration
  def change
    remove_column :lti_apps, :cartridge
    add_column :lti_apps, :cartridge_id, :integer
    add_index :lti_apps, :cartridge_id
  end
end
