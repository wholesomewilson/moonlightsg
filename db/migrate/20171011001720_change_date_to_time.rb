class ChangeDateToTime < ActiveRecord::Migration
  def change
    add_column :lessons, :start_date, :date
    add_column :lessons, :end_date, :date
  end
end
