class SendRsvpMailJob < ActiveJob::Base
  queue_as :default

  def perform(current_user)
    @user = current_user
    RsvpSuccessMailer.rsvp_success_email(@user).deliver_later
  end
end
