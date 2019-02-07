class AddLessonIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :lesson_id, :integer
  end
end
