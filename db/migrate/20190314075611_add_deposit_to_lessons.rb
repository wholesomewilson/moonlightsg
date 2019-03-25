class AddDepositToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :deposit, :decimal, :precision => 8, :scale => 2
  end
end
