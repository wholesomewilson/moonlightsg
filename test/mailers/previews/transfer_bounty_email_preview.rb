# Preview all emails at http://localhost:3000/rails/mailers/transfer_bounty_email
class TransferBountyEmailPreview < ActionMailer::Preview
  def transfer_bounty_email_preview
    TransferBountyEmail.transfer_bounty_email(Lesson.last.id)
  end
end
