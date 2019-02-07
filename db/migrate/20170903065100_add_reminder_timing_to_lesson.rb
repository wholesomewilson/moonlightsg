class AddReminderTimingToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :hours_reminder_email, :integer
    add_column :lessons, :hours_reminder_sms, :integer
  end
end
