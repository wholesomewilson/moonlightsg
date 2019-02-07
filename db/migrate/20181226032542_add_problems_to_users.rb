class AddProblemsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ongoing_problems_owner, :string
    add_column :users, :completed_problems_owner, :string
    add_column :users, :ongoing_problems_solver, :string
    add_column :users, :completed_problems_solver, :string
  end
end
