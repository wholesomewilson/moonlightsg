class AddChildIndexToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :child_index, :integer
  end
end
