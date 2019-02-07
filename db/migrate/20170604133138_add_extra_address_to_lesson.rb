class AddExtraAddressToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :address_street, :string
    add_column :lessons, :address_unit, :string
    add_column :lessons, :address_country, :string
    add_column :lessons, :address_city, :string
  end
end
