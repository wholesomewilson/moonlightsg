class CreateChatimages < ActiveRecord::Migration
  def change
    create_table :chatimages do |t|
      t.string :image
      t.integer :message_id
      t.timestamps null: false
    end
  end
end
