class AddBidWithdrawToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :bid_withdraw, :datetime
  end
end
