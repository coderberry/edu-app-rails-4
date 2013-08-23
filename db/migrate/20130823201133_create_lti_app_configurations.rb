class CreateLtiAppConfigurations < ActiveRecord::Migration
  def change
    create_table :lti_app_configurations do |t|
      t.string :short_name, null: false
      t.json :config
      t.references :user, index: true

      t.timestamps
    end

    add_index :lti_app_configurations, :short_name, unique: true
  end
end
