class AddStartTimeAndendTimeToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :start_time, :time
    add_column :lessons, :end_time, :time
  end
end
