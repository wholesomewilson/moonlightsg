class AddLessonIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :timezone_offset, :integer
  end
end
