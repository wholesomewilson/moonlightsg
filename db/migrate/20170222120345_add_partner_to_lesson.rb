class AddPartnerToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :partner_name, :string
    add_column :lessons, :partner_description, :string
  end
end
