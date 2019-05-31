class CreateTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.references :user, index: true, foreign_key: true
      t.text :body
      t.text :improve
      t.timestamps null: false
    end
  end
end
