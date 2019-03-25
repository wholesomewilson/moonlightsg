class ChangeBountyTransferredIdTypeInLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :bounty_transferred_id
    add_column :lessons, :bounty_transferred_id, :string
  end
end
