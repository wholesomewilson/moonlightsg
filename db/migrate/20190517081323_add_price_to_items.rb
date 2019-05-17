class AddPriceToItems < ActiveRecord::Migration
  def change
    add_column :items, :price_sg, :decimal, :precision => 8, :scale => 2
    add_column :items, :price_my, :decimal, :precision => 8, :scale => 2
  end
end
