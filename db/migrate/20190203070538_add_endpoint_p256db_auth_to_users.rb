class AddEndpointP256dbAuthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :endpoint, :string
    add_column :users, :p256dh, :string
    add_column :users, :auth, :string
  end
end
