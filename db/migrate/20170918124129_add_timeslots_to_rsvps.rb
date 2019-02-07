class AddTimeslotsToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :timeslots, :string
  end
end
