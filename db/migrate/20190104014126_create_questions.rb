class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :body
      t.references :lesson
      t.timestamps null: false
    end
  end
end
