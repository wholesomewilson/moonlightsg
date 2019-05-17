class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.datetime :deliver_datetime
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
