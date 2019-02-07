class AddPhotoToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :photo, :string
  end
end
