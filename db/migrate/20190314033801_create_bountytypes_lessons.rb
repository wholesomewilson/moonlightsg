class CreateBountytypesLessons < ActiveRecord::Migration
  def change
    create_table :bountytypes_lessons do |t|
      t.belongs_to :category
      t.belongs_to :lesson
    end
  end
end
