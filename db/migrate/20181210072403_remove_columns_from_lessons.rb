class RemoveColumnsFromLessons < ActiveRecord::Migration
  def change
    remove_column :lessons, :capacity
    remove_column :lessons, :partner_name
    remove_column :lessons, :partner_description
    remove_column :lessons, :partner_photo
    remove_column :lessons, :hours_reminder_email
    remove_column :lessons, :hours_reminder_sms
    remove_column :lessons, :timeslots
    remove_column :lessons, :full_timeslots
    remove_column :lessons, :status_timeslots
    remove_column :lessons, :available_timeslots
    remove_column :lessons, :start_date
    remove_column :lessons, :end_date
    remove_column :lessons, :time_email_reminder
    remove_column :lessons, :time_sms_reminder
    remove_column :lessons, :start_time
    remove_column :lessons, :end_time
  end
end
