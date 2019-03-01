class AddCancelAttributesToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :solver_cancel_job, :datetime
    add_column :lessons, :owner_agree_cancel, :boolean
    add_column :lessons, :solver_agree_cancel, :boolean
    add_column :lessons, :refund_bounty_tx_id, :string
  end
end
