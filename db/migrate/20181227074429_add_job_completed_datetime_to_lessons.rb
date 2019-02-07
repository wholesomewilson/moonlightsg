class AddJobCompletedDatetimeToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :job_completed_datetime, :datetime
  end
end
