class AddChildIndexToGuests < ActiveRecord::Migration
  def change
    add_column :guests, :child_index, :integer
  end
end
