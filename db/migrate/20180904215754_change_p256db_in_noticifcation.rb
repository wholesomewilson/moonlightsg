class ChangeP256dbInNoticifcation < ActiveRecord::Migration
  def change
    remove_column :notifications, :notifications
    add_column :notifications, :p256dh, :string
  end
end
