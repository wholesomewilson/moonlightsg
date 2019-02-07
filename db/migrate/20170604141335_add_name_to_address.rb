class AddNameToAddress < ActiveRecord::Migration
  def change
    add_column :lessons, :address_name, :string
  end
end
