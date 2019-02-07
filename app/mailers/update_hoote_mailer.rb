class UpdateHooteMailer < ApplicationMailer
  default from: "wilsonwan88@gmail.com"
  add_template_helper(EmailHelper)

  def update_hoote_email(user,rsvp)
    @lesson = Lesson.find_by_id(rsvp.attended_lesson_id)
    @all_rsvps = @lesson.rsvps
    mail(to: user.email, subject: "[Heads-up! There are some changes!] - #{@lesson.title}")
  end
end
