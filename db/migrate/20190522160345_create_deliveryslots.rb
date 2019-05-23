class CreateDeliveryslots < ActiveRecord::Migration
  def change
    create_table :deliveryslots do |t|
      t.date :date
      t.references :timeslot, index: true, foreign_key: true
      t.references :order, index: true, foreign_key: true
      t.integer :taken

      t.timestamps null: false
    end
  end
end
