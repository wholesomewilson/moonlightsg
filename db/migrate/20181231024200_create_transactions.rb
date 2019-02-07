class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :cash_out_id
      t.integer :amount
      t.integer :transaction_type
      t.references :wallet
      t.timestamps null: false
    end
  end
end
