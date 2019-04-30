class Answer < ActiveRecord::Base
  belongs_to :question
  after_create :new_answer_notification

  def new_answer_notification
    BidMailer.new_answer_email(self).deliver
  end

  handle_asynchronously :new_answer_notification, :run_at => Time.now
end
