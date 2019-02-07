class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :body
      t.references :user, index: true, foreign_key: true
      t.integer :lesson_id
      t.integer :rating_owner
      t.integer :rating_solver

      t.timestamps null: false
    end
  end
end
