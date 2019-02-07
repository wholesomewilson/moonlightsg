class RsvpReminderMailer < ApplicationMailer
  default from: "wilsonwan88@gmail.com"
  add_template_helper(EmailHelper)

  def rsvp_reminder_email(user,rsvp)
    @lesson = Lesson.find_by_id(rsvp.attended_lesson_id)
    @all_rsvps = @lesson.rsvps
    mail(to: user.email, subject: "[Reminder] - #{@lesson.title}")
  end
end
