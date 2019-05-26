class AddReminderToOrderitems < ActiveRecord::Migration
  def change
    add_column :orderitems, :reminder, :integer
  end
end
