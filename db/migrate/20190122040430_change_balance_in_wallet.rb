class ChangeBalanceInWallet < ActiveRecord::Migration
  def change
    change_column :wallets, :balance, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
