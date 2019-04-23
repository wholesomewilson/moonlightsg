class AddCardDetailsToWallets < ActiveRecord::Migration
  def change
    add_column :wallets, :last4, :string
    add_column :wallets, :brand, :string
  end
end
