class ChangeP256hToP256dh < ActiveRecord::Migration
  def change
    remove_column :notifications, :p256h
    add_column :notifications, :notifications, :string
  end
end
