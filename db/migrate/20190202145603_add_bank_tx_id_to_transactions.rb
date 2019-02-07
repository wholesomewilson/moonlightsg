class AddBankTxIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :bank_tx_id, :string
  end
end
