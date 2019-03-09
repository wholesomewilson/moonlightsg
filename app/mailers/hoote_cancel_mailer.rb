class HooteCancelMailer < ApplicationMailer
  default from: "wilsonwan88@gmail.com"
  add_template_helper(EmailHelper)

  def hoote_cancel_email(user)
    @lesson = Lesson.find_by_id(rsvp.attended_lesson_id)
    mail(to: user.email, subject: "[Job is Cancelled :(] - #{@lesson.title}")
  end
end
