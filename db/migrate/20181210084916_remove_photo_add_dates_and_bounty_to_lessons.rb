class RemovePhotoAddDatesAndBountyToLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :photo
    add_column :lessons, :date_to_be_completed, :date
    add_column :lessons, :datetime_to_be_completed, :datetime
    add_column :lessons, :date_to_be_awarded, :date
    add_column :lessons, :datetime_to_be_awarded, :datetime
    add_column :lessons, :bounty, :integer
    add_column :lessons, :job_photo, :string
  end
end
