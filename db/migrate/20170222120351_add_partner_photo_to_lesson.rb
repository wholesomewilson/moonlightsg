class AddPartnerPhotoToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :partner_photo, :string
  end
end
