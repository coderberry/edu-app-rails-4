class AddRegistrationCodes < ActiveRecord::Migration
  def change
    create_table :registration_codes do |t|
      t.integer :user_id
      t.string :email
      t.string :code
      t.datetime :valid_until
    end
    add_index :registration_codes, :code
  end
end
