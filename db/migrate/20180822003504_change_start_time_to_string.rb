class ChangeStartTimeToString < ActiveRecord::Migration
  def change
    remove_column :lessons, :start_time
    remove_column :lessons, :end_time
    add_column :lessons, :start_time, :string
    add_column :lessons, :end_time, :string
  end
end
