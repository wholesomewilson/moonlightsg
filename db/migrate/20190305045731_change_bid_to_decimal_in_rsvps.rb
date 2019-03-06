class ChangeBidToDecimalInRsvps < ActiveRecord::Migration
  def change
    remove_column :rsvps, :bid
    add_column :rsvps, :bid, :decimal, :precision => 8, :scale => 2
  end
end
