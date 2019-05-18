class AddNameAndContactNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :name, :string
    add_column :orders, :contact_no, :string
  end
end
