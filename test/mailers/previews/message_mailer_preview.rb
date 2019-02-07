# Preview all emails at http://localhost:3000/rails/mailers/message_mailer
class MessageMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/message_mailer/new_message_email
  def new_message_email
    MessageMailer.new_message_email(Conversation.last, Message.last.id)
  end

end
