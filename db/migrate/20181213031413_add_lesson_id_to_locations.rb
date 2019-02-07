class AddLessonIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :lesson_id, :integer
    add_index :locations, :lesson_id
  end
end
