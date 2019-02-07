class AddSentAtTimezoneToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sent_at_timezone, :datetime
  end
end
