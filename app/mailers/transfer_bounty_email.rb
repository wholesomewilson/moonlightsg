class TransferBountyEmail < ApplicationMailer
  def transfer_bounty_email(id)
    @lesson = Lesson.find(id)
    mail(to: 'wilsonwan88@gmail.com', subject: "[Transfer Bounty] - #{@lesson.title}")
  end
end
