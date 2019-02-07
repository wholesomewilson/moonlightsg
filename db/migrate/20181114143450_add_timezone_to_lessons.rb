class AddTimezoneToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :timezone_offset, :integer
  end
end
