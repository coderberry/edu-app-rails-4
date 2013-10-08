class CreateLtiAppConfigOptions < ActiveRecord::Migration
  def change
    create_table :lti_app_config_options do |t|
      t.references :lti_app, index: true
      t.string :name, null: false
      t.string :param_type
      t.string :default_value
      t.string :description
      t.boolean :is_required

      t.timestamps
    end
  end
end
