class AddCountryCodeContactToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country_code_contact, :string
  end
end
