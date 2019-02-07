class SendWelcomeMailJob < ActiveJob::Base
  queue_as :default

  def perform(current_user)
    @user = current_user
    WelcomeMailer.welcome_email(@user).deliver_later
  end
end
