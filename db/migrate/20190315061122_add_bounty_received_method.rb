class AddBountyReceivedMethod < ActiveRecord::Migration
  def change
    add_column :lessons, :bounty_received_method, :integer
  end
end
