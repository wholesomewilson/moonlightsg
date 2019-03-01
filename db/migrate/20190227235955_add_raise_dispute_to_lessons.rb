class AddRaiseDisputeToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :raise_a_dispute, :datetime
  end
end
