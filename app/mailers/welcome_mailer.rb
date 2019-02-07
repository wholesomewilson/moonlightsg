class WelcomeMailer < ApplicationMailer
  default from: "wilsonwan88@gmail.com"
  add_template_helper(EmailHelper)

  def welcome_email(current_user)
    @user = current_user
    mail(to: @user.email, subject: 'Welcome to Hootenanny!')
  end
end
