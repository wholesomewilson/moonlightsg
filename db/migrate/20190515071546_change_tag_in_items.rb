class ChangeTagInItems < ActiveRecord::Migration
  def change
    remove_column :items, :tag
    add_column :items, :tag, :string
  end
end
