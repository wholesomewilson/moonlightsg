class AddBountyTypeToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :bounty_type, :integer
  end
end
