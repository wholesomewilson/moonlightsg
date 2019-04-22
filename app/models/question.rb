class Question < ActiveRecord::Base
  belongs_to :lesson
  has_one :answer, dependent: :destroy
  after_create :new_question_notification

  def new_question_push
    @solver = User.find(user_id)
    @lesson = self.lesson
    @owner = @lesson.organizer
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: @lesson.title,
      body: "#{@solver.first_name} has a question.",
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(@lesson)
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

  def new_question_notification
    @lesson = Lesson.find(lesson_id)
    BidMailer.new_question_email(self).deliver
    #self.new_question_push
  end

  handle_asynchronously :new_question_notification, :run_at => Time.now
end
