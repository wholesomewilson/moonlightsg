class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :brand
      t.integer :tag
      t.string :item_photo
      t.string :description

      t.timestamps null: false
    end
  end
end
