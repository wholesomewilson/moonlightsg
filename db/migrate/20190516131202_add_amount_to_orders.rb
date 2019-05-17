class AddAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :amount, :decimal, :precision => 8, :scale => 2
  end
end
