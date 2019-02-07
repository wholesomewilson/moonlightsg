class AddJobVerifiedDateToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :job_verified_datetime, :datetime
  end
end
