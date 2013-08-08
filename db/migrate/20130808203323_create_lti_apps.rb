class CreateLtiApps < ActiveRecord::Migration
  def change
    create_table :lti_apps do |t|
      t.references :user, index: true
      t.string :short_name, null: false
      t.string :name, null: false
      t.string :short_description
      t.text :description
      t.string :status, default: "pending", null: false
      t.text :testing_instructions
      t.string :support_url, limit: 1000
      t.string :author_name
      t.boolean :is_public, default: false
      t.string :app_type
      t.string :ims_cert_url, limit: 1000
      t.string :preview_url, limit: 1000
      t.string :config_url, limit: 1000
      t.string :data_url, limit: 1000
      t.string :banner_image_url, limit: 1000
      t.string :logo_image_url, limit: 1000
      t.string :icon_image_url, limit: 1000
      t.json :cartridge

      t.timestamps
    end

    add_index :lti_apps, :short_name, unique: true
  end
end
