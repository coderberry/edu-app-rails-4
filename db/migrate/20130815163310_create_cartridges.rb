class CreateCartridges < ActiveRecord::Migration
  def change
    create_table :cartridges do |t|
      t.string :uid
      t.json :data
      t.string :name, null: false
      t.references :user, index: true

      t.timestamps
    end

    add_index :cartridges, :uid, unique: true
  end
end
