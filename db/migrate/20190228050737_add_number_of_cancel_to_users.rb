class AddNumberOfCancelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :owner_cancel, :integer
    add_column :users, :solver_cancel, :integer
  end
end
