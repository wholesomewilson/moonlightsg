class AddJobPaidDatetimeToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :job_paid_datetime, :datetime
  end
end
