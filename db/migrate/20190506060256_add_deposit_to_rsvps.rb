class AddDepositToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :deposit, :decimal, :precision => 8, :scale => 2
  end
end
