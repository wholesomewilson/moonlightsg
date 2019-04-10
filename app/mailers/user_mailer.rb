class UserMailer < ApplicationMailer
  add_template_helper(EmailHelper)
  def password_change(record, opts={})
    opts[:from] = 'Moonlight <notifications@moonlight.sg>'
    opts[:reply_to] = 'Moonlight <notifications@moonlight.sg>'
    super
  end
  def registration_confirmation(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registration Confirmation")
 end
end
