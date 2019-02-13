class Rsvp < ActiveRecord::Base
  belongs_to :attended_lesson, class_name: "Lesson"
  belongs_to :attendee, class_name: "User"
  has_many :guests, dependent: :destroy
  accepts_nested_attributes_for :guests, reject_if: :all_blank

  #after_create :reminder_email
  #after_create :queue_reminder_push_notification
  #after_create :reminder_push_notification
  #after_create :success_email
  #after_create :success_push
  #after_create :reminder_push_notification
  #before_destroy :remove_email_push_jobs
  after_create :receive_bid_notification
  before_destroy :remove_from_solvers

  #When to send

  def when_to_run_email
    @lesson = Lesson.find(attended_lesson_id)
    @start_time =  @lesson.datetime_awarded - @lesson.timezone_offset.hours - 30.minutes
  end

  def when_to_run_push_notification
    @lesson = Lesson.find(attended_lesson_id)
    @start_time =  @lesson.datetime_awarded - @lesson.timezone_offset.hours - 30.minutes
  end

  #Success Notification

  def remove_from_solvers
    User.find(attendee_id).remove_from_ongoing_and_completed(attended_lesson_id)
  end

  def success_email
    if attendee_id.blank?
      @user = guests.last
    else
      @user = User.find(attendee_id)
    end
    RsvpSuccessMailer.rsvp_success_email(@user,self).deliver
  end

  def success_push
    @lesson = Lesson.find(attended_lesson_id)
    @message = {
      title: @lesson.title,
      body: @lesson.datetime_awarded.strftime("%A, %d %B %Y %l:%M %P"),
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(@lesson)
      }
    }
    Webpush.payload_send(
      message: JSON.generate(@message),
      endpoint: self.endpoint,
      p256dh: self.p256dh,
      auth: self.auth,
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

  # Notify our appointment attendee X minutes before the appointment time

  def reminder_email
    if attendee_id.blank?
      @user = guests.last
    else
      @user = User.find(attendee_id)
    end
    @job = RsvpReminderMailer.delay(:run_at => when_to_run_email).rsvp_reminder_email(@user,self)
    self.update_attribute(:email_job_id, @job.id)
  end

  def reminder_push_notification
    @lesson = Lesson.find(attended_lesson_id)
    @message = {
      title: @lesson.title,
      body: "Upcoming Job",
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(@lesson)
      }
    }
    Webpush.payload_send(
      message: JSON.generate(@message),
      endpoint: self.endpoint,
      p256dh: self.p256dh,
      auth: self.auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'mailto:sender@example.com',
        #public_key: ENV['VAPID_PUBLIC'],
        #private_key: ENV['VAPID_PRIVATE']
        public_key:'BAFnd1hdV8lu1-ZOG8eizCVSmXRE5FmQPbMDBzpsfcDiW5xxf6KnPAAIk3L6BFy8cyxNh_rWe1NijLNhTZJZ5XQ',
        private_key: 'O_FglZbJq9_QHQRMBw_p8HCEwCPs_CKEatsj08LRYRo',
        expiration: 24 * 60 * 60
      }
    )
  end

  #Update Notification

  def update_email
    if attendee_id.blank?
      @user = guests.last
    else
      @user = User.find(attendee_id)
    end
    UpdateHooteMailer.update_hoote_email(@user,self).deliver
  end

  def update_push
    @lesson = Lesson.find(attended_lesson_id)
    @message = {
      title: @lesson.title,
      body: "Heads-up! Minor changes to the Hoote!",
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(@lesson)
      }
    }
    Webpush.payload_send(
      message: JSON.generate(@message),
      endpoint: self.endpoint,
      p256dh: self.p256dh,
      auth: self.auth,
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

  # Cancel Notification

  def cancel_email
    if attendee_id.blank?
      @user = guests.last
    else
      @user = User.find(attendee_id)
    end
    HooteCancelMailer.hoote_cancel_email(@user).deliver
  end

  def cancel_push
    @lesson = Lesson.find(attended_lesson_id)
    @message = {
      title: @lesson.title,
      body: "Oh no! Hoote is cancelled :(",
    }
    Webpush.payload_send(
      message: JSON.generate(@message),
      endpoint: self.endpoint,
      p256dh: self.p256dh,
      auth: self.auth,
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

  #Get Job id

  def queue_reminder_push_notification
    @job = self.delay(:run_at => when_to_run_email).reminder_push_notification
    self.update_attribute(:push_job_id, @job.id)
  end

  #Remove email & push jobs

  def remove_email_push_jobs
    Delayed::Job.find(self.email_job_id).destroy if self.email_job_id
    Delayed::Job.find(self.push_job_id).destroy if self.push_job_id
  end

  #Remove old jobs and Queue new email & push if there is changes to Hoote's start_time
  def follow_up_update_jobs
    self.remove_email_push_jobs
    self.reminder_email
    self.queue_reminder_push_notification
  end

  #Update attendees on Hoote's changes
  def follow_up_update
    self.update_email
    self.update_push
  end

  def follow_up_cancelled_hoote
    self.remove_email_push_jobs
    self.cancel_email
    self.cancel_push
  end


  def receive_bid_push
    @lesson = Lesson.find(attended_lesson_id)
    @solver = self.attendee
    @user = @lesson.organizer
    @endpoint = @user.endpoint
    @p256dh = @user.p256dh
    @auth = @user.auth
    @bid_amount = ActionController::Base.helpers.number_to_currency(bid)
    @message = {
      title: "There is a new bid for #{@lesson.title}! ",
      body: "#{@bid_amount} from #{@solver.first_name}",
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

  def receive_bid_notification
    @lesson = Lesson.find(attended_lesson_id)
    BidMailer.receive_bid_email(@lesson, self).deliver
    self.receive_bid_push
  end

  handle_asynchronously :success_push, :run_at => Time.now
  handle_asynchronously :success_email, :run_at => Time.now
  handle_asynchronously :update_push, :run_at => Time.now
  handle_asynchronously :update_email, :run_at => Time.now
  handle_asynchronously :cancel_push, :run_at => Time.now
  handle_asynchronously :cancel_email, :run_at => Time.now

  handle_asynchronously :receive_bid_notification, :run_at => Time.now
end
