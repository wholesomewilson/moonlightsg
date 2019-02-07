class AddAwardeeIdToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :awardee_id, :integer
  end
end
