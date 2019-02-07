class ChangeReadStatusToInteger < ActiveRecord::Migration
  def change
    remove_column :conversations, :read_status
    add_column :conversations, :read_status, :integer
  end
end
