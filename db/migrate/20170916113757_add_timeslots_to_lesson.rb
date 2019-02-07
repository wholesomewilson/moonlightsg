class AddTimeslotsToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :timeslots, :string
  end
end
