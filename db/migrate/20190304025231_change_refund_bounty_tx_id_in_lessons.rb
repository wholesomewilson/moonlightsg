class ChangeRefundBountyTxIdInLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :refund_bounty_tx_id
    add_column :lessons, :refund_bounty_tx_id, :integer
  end
end
