class AddContactNumberToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :contact_no, :string
  end
end
