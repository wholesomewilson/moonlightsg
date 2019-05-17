class AddPaymentReceviedDatetimeAndPaymentTransferredIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_received_datetime, :datetime
    add_column :orders, :payment_transferred_id, :string
  end
end
