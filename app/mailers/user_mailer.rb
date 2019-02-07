class UserMailer < ApplicationMailer
  default from: "wilsonwan88@gmail.com"
  add_template_helper(EmailHelper)

  def registration_confirmation(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registration Confirmation")
 end
end
