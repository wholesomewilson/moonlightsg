class ChangeReadToReadStatusInConversations < ActiveRecord::Migration
  def change
    remove_column :conversations, :read
    add_column :conversations, :read_status, :boolean, :default => false
  end
end
