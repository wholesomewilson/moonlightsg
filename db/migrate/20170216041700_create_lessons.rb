class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.date :date
      t.string :title
      t.text :description
      t.string :location
      t.integer :capacity
      t.string :tag
      t.integer :organizer_id

      t.timestamps null: false
    end
  end
end
