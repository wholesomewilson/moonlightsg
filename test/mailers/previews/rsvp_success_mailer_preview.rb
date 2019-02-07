# Preview all emails at http://localhost:3000/rails/mailers/rsvp_success_mailer
class RsvpSuccessMailerPreview < ActionMailer::Preview
  def rsvp_success_email_preview
    RsvpSuccessMailer.rsvp_success_email(User.first,Rsvp.last)
  end
end
