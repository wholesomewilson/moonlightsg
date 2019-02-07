class ChangeBalanceFromIntegerToDecimal < ActiveRecord::Migration
  def change
    remove_column :wallets, :balance
    remove_column :wallets, :amt_paid
    remove_column :wallets, :amt_received
    remove_column :lessons, :bounty
    remove_column :transactions, :amount
    add_column :wallets, :balance, :decimal, :precision => 8, :scale => 2
    add_column :wallets, :amt_paid, :decimal, :precision => 8, :scale => 2
    add_column :wallets, :amt_received, :decimal, :precision => 8, :scale => 2
    add_column :lessons, :bounty, :decimal, :precision => 8, :scale => 2
    add_column :transactions, :amount, :decimal, :precision => 8, :scale => 2
  end
end
