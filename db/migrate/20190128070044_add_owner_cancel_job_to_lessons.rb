class AddOwnerCancelJobToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :owner_cancel_job, :datetime
  end
end
