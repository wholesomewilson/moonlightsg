# Preview all emails at http://localhost:3000/rails/mailers/update_hoote_mailer
class UpdateHooteMailerPreview < ActionMailer::Preview
  def update_hoote_email_preview
    UpdateHooteMailer.update_hoote_email(User.first,Rsvp.last)
  end
end
