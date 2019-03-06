class AddAutoRefundJobIdToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :owner_auto_refund_job_id, :integer
    add_column :lessons, :solver_auto_refund_job_id, :integer
  end
end
