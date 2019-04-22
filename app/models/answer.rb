class Answer < ActiveRecord::Base
  belongs_to :question
  after_create :new_answer_notification

  def new_answer_push
    @question = self.question
    @lesson = @question.lesson
    @solver = User.find(@question.user_id)
    @owner = @lesson.organizer
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: @lesson.title,
      body: "#{@owner.first_name} answered your question!.",
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

  def new_answer_notification
    BidMailer.new_answer_email(self).deliver
    #self.new_answer_push
  end

  handle_asynchronously :new_answer_notification, :run_at => Time.now
end
