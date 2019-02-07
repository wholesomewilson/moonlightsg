class AddBountyReceivedDatetimeToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :bounty_received_datetime, :datetime
  end
end
