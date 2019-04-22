class Conversation < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :sender_id, class_name:"User"
  belongs_to :recipient, :foreign_key => :recipient_id, class_name:"User"
  has_many :messages, dependent: :destroy
  validates_uniqueness_of :sender_id, :scope => :recipient_id

  scope :between, -> (sender_id, recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id = ?)", sender_id, recipient_id, recipient_id, sender_id)
  end

  def when_to_run
    Time.now + 2.minutes
  end

  def message_actions
    @job = self.delay(:run_at => when_to_run).message_notification
    self.update_column(:message_notification_job_id, @job.id)
  end

  def message_notification
    @message_id = self.messages.last.id
    MessageMailer.new_message_email(self, @message_id).deliver
    #self.message_push_notification(@message_id)
    self.update_column(:message_notification_job_id, nil)
  end

  def message_push_notification(message_id)
    @new_message = Message.find(message_id)
    @user_id = @new_message.user_id
    if @user_id == sender_id
      @user = User.find(recipient_id)
      @sender = User.find(sender_id)
    else
      @user = User.find(sender_id)
      @sender = User.find(recipient_id)
    end
    @endpoint = @user.endpoint
    @p256dh = @user.p256dh
    @auth = @user.auth
    @message = {
      title: "#{@sender.first_name} sent you a new message!",
      body: @new_message.body,
      data: {
        url: Rails.application.routes.url_helpers.lesson_solver_path
      }
    }
    Webpush.payload_send(
      message: JSON.generate(@message),
      endpoint: @endpoint,
      p256dh: @p256dh,
      auth: @auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'mailto:sender@example.com',
        #public_key: ENV['VAPID_PUBLIC'],
        #private_key: ENV['VAPID_PRIVATE']
        public_key:'BDCyQd_y3d3kX15afKF7OF44te-Y3dCcVz0LIcPNlRpEHFYB58B2noKwzBsfRaf3ZvALRm998-lMv69IEXfOISQ',
        private_key: '1rC78sAgO8PZ66VJ7cfT1IiLehEXQ25RyTHyG3T-mk8',
        expiration: 24 * 60 * 60
      }
    )
  end
end
