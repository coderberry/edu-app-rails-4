class CreateCartridges < ActiveRecord::Migration
  def change
    create_table :cartridges do |t|
      t.string :uid
      t.string :name, null: false
      t.text :xml
      t.references :user, index: true

      t.timestamps
    end

    add_index :cartridges, :uid, unique: true
  end
end
