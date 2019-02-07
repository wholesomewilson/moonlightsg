class ChangeDateToTime < ActiveRecord::Migration
  def change
    remove_column :lessons, :start_date, :time
    remove_column :lessons, :end_date, :time
    add_column :lessons, :start_date, :date
    add_column :lessons, :end_date, :date
  end
end
