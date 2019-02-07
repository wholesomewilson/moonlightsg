class AddBidToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :bid, :integer
  end
end
