class AddTwitterNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_nickname, :string
    add_index :users, :twitter_nickname, unique: true
  end
end
