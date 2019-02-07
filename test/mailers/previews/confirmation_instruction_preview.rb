# Preview all emails at http://localhost:3000/rails/mailers/confirmation_instructions
class ConfirmationMailerPreview < ActionMailer::Preview

  def confirmation_instructions
    ConfirmationMailer.confirmation_instructions(User.first, "faketoken", {})
  end

  def reset_password_instructions
    ConfirmationMailer.reset_password_instructions(User.first, "faketoken", {})
  end

  def unlock_instructions
    ConfirmationMailer.unlock_instructions(User.first, "faketoken", {})
  end

end
