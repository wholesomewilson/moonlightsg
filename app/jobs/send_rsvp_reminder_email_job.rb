class SendRsvpReminderEmailJob < ActiveJob::Base
  queue_as :default

  def perform(current_user, date_reminder_email)
    @user = current_user
    @date_reminder_email = date_reminder_email
    RsvpReminderMailer.delay(run_at: @date_reminder_email).rsvp_reminder_email(@user)
  end
end
