class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :contact_number, :string
    add_column :users, :company, :string
    add_column :users, :website, :string
    add_column :users, :address, :string
    add_column :users, :address_2, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :postal_code, :string
    add_column :users, :gender, :string
    add_column :users, :birth_date, :date
    add_column :users, :age, :integer
  end
end
