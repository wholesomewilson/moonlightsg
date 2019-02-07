class AddRatingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rating_owner, :decimal, precision: 3, scale: 2, default: 0
    add_column :users, :rating_solver, :decimal, precision: 3, scale: 2, default: 0
  end
end
