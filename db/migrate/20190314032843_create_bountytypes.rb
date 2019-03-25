class CreateBountytypes < ActiveRecord::Migration
  def change
    create_table :bountytypes do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
