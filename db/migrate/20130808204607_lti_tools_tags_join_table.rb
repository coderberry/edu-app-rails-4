class LtiToolsTagsJoinTable < ActiveRecord::Migration
  def change
    create_table :lti_apps_tags do |t|
      t.integer :lti_app_id
      t.integer :tag_id
    end

    add_index :lti_apps_tags, [ :lti_app_id, :tag_id ], name: 'index_lti_apps_tags', unique: true
  end
end
