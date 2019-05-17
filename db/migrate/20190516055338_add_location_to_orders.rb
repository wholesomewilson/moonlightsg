class AddLocationToOrders < ActiveRecord::Migration
  def change
    add_reference :locations, :order, index: true, foreign_key: true
  end
end
