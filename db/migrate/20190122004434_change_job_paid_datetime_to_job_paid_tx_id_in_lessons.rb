class ChangeJobPaidDatetimeToJobPaidTxIdInLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :job_paid_datetime
    add_column :lessons, :bounty_transferred_id, :integer
  end
end
