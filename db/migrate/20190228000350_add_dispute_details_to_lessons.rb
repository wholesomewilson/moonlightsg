class AddDisputeDetailsToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :dispute_details, :text
  end
end
