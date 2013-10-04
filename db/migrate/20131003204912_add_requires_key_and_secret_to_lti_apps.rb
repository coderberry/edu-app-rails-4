class AddRequiresKeyAndSecretToLtiApps < ActiveRecord::Migration
  def change
    add_column :lti_apps, :requires_secret, :boolean, :default => true
  end
end
