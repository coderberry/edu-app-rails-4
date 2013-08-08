class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :short_name
      t.string :name
      t.string :context

      t.timestamps
    end

    add_index :tags, :short_name, unique: true
  end
end
