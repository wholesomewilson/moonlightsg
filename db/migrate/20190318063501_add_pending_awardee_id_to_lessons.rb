class AddPendingAwardeeIdToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :pending_awardee_id, :integer
  end
end
