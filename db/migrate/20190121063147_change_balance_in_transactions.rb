class ChangeBalanceInTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :amount
    add_column :transactions, :amount, :decimal, :precision => 8, :scale => 2
  end
end
