class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :block_no
      t.string :road_name
      t.string :building
      t.string :address
      t.string :postal
      t.float :lat, {:precision=>10, :scale=>6}
      t.float :lng, {:precision=>10, :scale=>6}
      t.string :unit_no
      t.string :country
      t.timestamps null: false
    end
  end
end
