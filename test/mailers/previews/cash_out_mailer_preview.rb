# Preview all emails at http://localhost:3000/rails/mailers/cash_out_mailer
class CashOutMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/cash_out_mailer/cash_out_request_email
  def cash_out_request_email
    CashOutMailer.cash_out_request_email(User.first, 50)
  end

  # Preview this email at http://localhost:3000/rails/mailers/cash_out_mailer/cash_out_success_email
  def cash_out_success_email
    CashOutMailer.cash_out_success_email(User.first, 50)
  end

end
