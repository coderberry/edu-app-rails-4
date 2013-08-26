class CreateLtiAppConfigurations < ActiveRecord::Migration
  def change
    create_table :lti_app_configurations do |t|
      t.string :uid, null: false
      t.json :config
      t.references :user, index: true
      t.timestamps
    end

    add_index :lti_app_configurations, :uid, unique: true
  end
end
