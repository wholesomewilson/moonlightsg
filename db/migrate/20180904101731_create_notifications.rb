class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :endpoint
      t.string :p256h
      t.string :auth
    end
  end
end
