# Preview all emails at http://localhost:3000/rails/mailers/rsvp_reminder_mailer
class RsvpReminderMailerPreview < ActionMailer::Preview
  def rsvp_reminder_email_preview
    RsvpReminderMailer.rsvp_reminder_email(User.first, Rsvp.last)
  end
end
