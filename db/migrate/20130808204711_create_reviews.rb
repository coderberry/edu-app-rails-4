class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :membership, index: true
      t.references :user, index: true
      t.references :lti_app, index: true
      t.integer :rating
      t.text :comments

      t.timestamps
    end
  end
end
