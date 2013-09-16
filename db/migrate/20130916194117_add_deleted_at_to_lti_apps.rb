class AddDeletedAtToLtiApps < ActiveRecord::Migration
  def change
    add_column :lti_apps, :deleted_at, :datetime
  end
end
