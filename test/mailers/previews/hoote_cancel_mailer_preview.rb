# Preview all emails at http://localhost:3000/rails/mailers/hoote_cancel_mailer
class HooteCancelMailerPreview < ActionMailer::Preview
  def hoote_cancel_email_preview
    HooteCancelMailer.hoote_cancel_email(User.first,Rsvp.last)
  end
end
