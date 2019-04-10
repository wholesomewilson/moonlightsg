class CashOutMailer < ApplicationMailer

add_template_helper(EmailHelper)

  def cash_out_request_email(user, amount)
    @user = user
    @amount = view_context.number_to_currency(amount)
    mail(to: @user.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight+payment@gmail.com', subject: "Your Cash Out request is received! [We're working on it!]")
  end

  def cash_out_success_email(user, amount)
    @user = user
    @amount = view_context.number_to_currency(amount)
    mail(to: @user.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Your Cash Out request is succesful! Ka-ching!")
  end
end
