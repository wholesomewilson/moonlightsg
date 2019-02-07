class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.belongs_to :attendee, index: true
      t.belongs_to :attended_lesson, index: true
      t.integer :queue_number
      t.timestamps null: false
    end
  end
end
