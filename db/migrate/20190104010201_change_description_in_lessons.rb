class ChangeDescriptionInLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :description
    add_column :lessons, :description, :text
  end
end
