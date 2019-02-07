class RenameLocationToAddressPostal < ActiveRecord::Migration
  def change
    rename_column :lessons, :location, :address_postal
  end
end
