class ChangeNameInLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :date_to_be_completed, :date
    remove_column :lessons, :datetime_to_be_completed, :datetime
    remove_column :lessons, :date_to_be_awarded, :date
    remove_column :lessons, :datetime_to_be_awarded, :datetime
    add_column :lessons, :date_completed, :date
    add_column :lessons, :datetime_completed, :datetime
    add_column :lessons, :date_awarded, :date
    add_column :lessons, :datetime_awarded, :datetime
  end
end
