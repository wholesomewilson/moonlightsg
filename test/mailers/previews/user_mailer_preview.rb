# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def confirmation_email_preview
    UserMailer.registration_confirmation(User.first)
  end
end
