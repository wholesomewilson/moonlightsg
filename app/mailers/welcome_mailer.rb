class WelcomeMailer < ApplicationMailer
  default from: "wilsonwan88@gmail.com"
  add_template_helper(EmailHelper)

  def welcome_email(current_user)
    @user = current_user
    mail(to: @user.email, from: "Wilson <wilsonwan@moonlight.sg>", subject: 'Welcome to Moonlight!')
  end
end
