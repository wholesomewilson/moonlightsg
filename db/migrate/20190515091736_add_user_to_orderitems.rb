class AddUserToOrderitems < ActiveRecord::Migration
  def change
    add_reference :orderitems, :user, index: true, foreign_key: true
  end
end
