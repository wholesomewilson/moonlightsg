class AddTokenToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :token, :integer, limit: 6
  end
end
