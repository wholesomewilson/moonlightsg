class AddTimeEmailReminderToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :time_email_reminder, :time
    add_column :lessons, :time_sms_reminder, :time
  end
end
