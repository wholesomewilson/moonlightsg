class CreateDisputes < ActiveRecord::Migration
  def change
    create_table :disputes do |t|
      t.text :body
      t.belongs_to :lesson, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
