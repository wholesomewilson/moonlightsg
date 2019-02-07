class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :first_name
      t.string :last_name
      t.string :contact_number
      t.string :email
      t.references :rsvp

      t.timestamps null: false
    end
  end
end
