class MessageMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.message_mailer.new_message_email.subject
  #
  def new_message_email(conversation, message_id)
    @message = Message.find(message_id)
    @user_id = @message.user_id
    @sender_id = conversation.sender_id
    @recipient_id = conversation.recipient_id
    if @user_id == @sender_id
      @user = User.find(@recipient_id)
      @sender = User.find(@sender_id)
    else
      @user = User.find(@sender_id)
      @sender = User.find(@recipient_id)
    end
    mail(to: @user.email, from: "Moonlight <notifications@moonlight.sg>", subject: "#{@sender.first_name} sent you a new message!")
  end
end
