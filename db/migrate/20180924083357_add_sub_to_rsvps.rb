class AddSubToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :endpoint, :string, unique: true
    add_column :rsvps, :auth, :string, unique: true
    add_column :rsvps, :p256dh, :string, unique: true
  end
end
