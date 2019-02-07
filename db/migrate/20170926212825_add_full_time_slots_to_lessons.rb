class AddFullTimeSlotsToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :full_timeslots, :string
  end
end
