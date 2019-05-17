class CreateOrderitems < ActiveRecord::Migration
  def change
    create_table :orderitems do |t|
      t.references :item, index: true, foreign_key: true
      t.references :order, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :quantity
      t.integer :status
      t.timestamps null: false
    end
  end
end
