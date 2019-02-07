class CreateWalletsTable < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.belongs_to :user, index: true
      t.string :customer_id
      t.integer :amt_received
      t.integer :amt_paid
      t.integer :balance
    end
  end
end
