class AddBlkNoToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :address_block_number, :string
  end
end
