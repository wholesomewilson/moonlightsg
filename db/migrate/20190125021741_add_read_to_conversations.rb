class AddReadToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :read, :boolean, :default => false
    remove_column :messages, :read
  end
end
