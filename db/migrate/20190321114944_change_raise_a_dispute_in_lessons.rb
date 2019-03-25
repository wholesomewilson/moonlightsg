class ChangeRaiseADisputeInLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :raise_a_dispute
    add_column :lessons, :raise_a_dispute_sponsor, :datetime
    add_column :lessons, :raise_a_dispute_hunter, :datetime
  end
end
