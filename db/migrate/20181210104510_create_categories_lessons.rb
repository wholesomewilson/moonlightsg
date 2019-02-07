class CreateCategoriesLessons < ActiveRecord::Migration
  def change
    create_table :categories_lessons do |t|
      t.belongs_to :category
      t.belongs_to :lesson
    end
  end
end
