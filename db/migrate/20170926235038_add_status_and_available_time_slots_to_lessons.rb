class AddStatusAndAvailableTimeSlotsToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :status_timeslots, :text
    add_column :lessons, :available_timeslots, :string
  end
end
