class Lesson < ActiveRecord::Base

before_destroy :close_conversation, if: -> {awardee_id.present?}
before_destroy :pass_to_rsvps_cancelled
before_destroy :remove_from_users
# Association
belongs_to :organizer, class_name: "User"
has_and_belongs_to_many :categories
has_many :rsvps, foreign_key: :attended_lesson_id, dependent: :destroy
has_many :attendees, through: :rsvps
has_many :answers, through: :questions
has_many :locations
has_many :questions, foreign_key: :lesson_id, dependent: :destroy
accepts_nested_attributes_for :rsvps, reject_if: :all_blank
accepts_nested_attributes_for :locations, reject_if: :all_blank
accepts_nested_attributes_for :questions, reject_if: :all_blank
accepts_nested_attributes_for :answers, reject_if: :all_blank
has_many :photos, dependent: :destroy
has_many :disputes, dependent: :destroy


# Search Function
  searchkick
  #after_commit :reindex_locations
  #scope :search_import, -> { includes(:locations) }

# Carrierwave
  #serialize :job_photo, JSON

# Google Maps
geocoded_by :address_postal
after_validation :geocode, if: ->(obj){ obj.address_postal.present? and obj.address_postal_changed? }

# Creating token
before_create :generate_token

#refactor time
validate :refactor_time

#remove special characters in tag
serialize :tag

# Trigger actions after Hoote is updated
#after_update :pass_to_rsvps

# Trigger actions after Hoote is cancelled


#Trigger actions after Job is created
after_create :pass_to_owner_ongoing_problems

after_update :pass_to_solver_ongoing_problems, if: -> {awardee_id_changed? && awardee_id.present?}
after_update :create_conversation, if: -> {awardee_id_changed? && awardee_id.present?}
after_update :award_bid_notification, if: -> {awardee_id_changed? && awardee_id.present?}

#Trigger actions after Job is completed
after_update :completed_job_notification, if: -> {job_completed_datetime_changed? && job_completed_datetime.present?}

#Trigger actions after Job is Verified
after_update :pass_to_owner_completed_problems, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :pass_to_solver_completed_problems, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :close_conversation, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :verified_job_notification, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :transfer_bounty_to_solver, if: -> {job_verified_datetime_changed? && bounty_received_datetime.present?}

#Trigger actions after Job is cancelled
after_update :owner_cancel_job_notification, if: -> {owner_cancel_job_changed? && owner_cancel_job.present?}
after_update :solver_cancel_job_actions, if: -> {solver_cancel_job_changed? && solver_cancel_job.present?}
after_update :solver_responds_cancel, if: -> {solver_agree_cancel_changed? && solver_agree_cancel.present?}
after_update :owner_responds_cancel, if: -> {owner_agree_cancel_changed? && owner_agree_cancel.present?}

#Trigger actions after Job is changes
#before_save :changes_to_job_notification, if: ->(obj){ title_changed? || tag_changed? || datetime_completed_changed? || contact_no_changed? || description_changed? || obj.locations.present? {|a| a.changed?} || obj.job_photo.present? {|a| a.changed?} }
before_save :changes_to_job_notification, if: ->(obj){ title_changed? || tag_changed? || datetime_completed_changed? || contact_no_changed? || description_changed? }
#Adding photos to existing job_photo
#before_validation { self.previous_images }
#before_save { self.add_previous_images }

def previous_images
  if self.job_photo.present?
    @images = self.photos
  end
end

def add_previous_images
  if defined?(@images) and @images.present?
    @images.each do |a|
      if !self[:job_photo].include?(a)
        self[:job_photo] << a
      end
    end
  end
end

  def pass_to_rsvps_cancelled
    self.rsvps.map {|rsvp| rsvp.follow_up_cancelled_hoote}
  end

  def pass_to_rsvps_time
    self.rsvps.map {|rsvp| rsvp.follow_up_update_jobs}
  end

  def pass_to_rsvps
    self.rsvps.map {|rsvp| rsvp.follow_up_update}
  end

  def pass_to_owner_ongoing_problems
    User.find_by_id(organizer_id).add_to_ongoing_problems_owner(id)
  end

  def pass_to_solver_ongoing_problems
    User.find_by_id(Rsvp.find_by_id(awardee_id).attendee_id).add_to_ongoing_problems_solver(id)
  end

  def pass_to_owner_completed_problems
    User.find_by_id(organizer_id).remove_from_ongoing_and_add_to_completed_problems_owner(id)
  end

  def pass_to_solver_completed_problems
    User.find_by_id(Rsvp.find_by_id(awardee_id).attendee_id).remove_from_ongoing_and_add_to_completed_problems_solver(id)
  end

  def close_conversation
    @conversation = Conversation.where(sender_id: organizer_id).where(recipient_id: Rsvp.find_by_id(awardee_id).attendee_id)
    if @conversation.present?
      Conversation.destroy(@conversation.first.id)
    end
  end

  def remove_from_users
    self.organizer.remove_from_ongoing_and_completed(id)
    Rsvp.find_by_id(awardee_id).attendee.remove_from_ongoing_and_completed(id)
  end

  def to_param
   "#{token}-#{title.parameterize}"
  end

  def generate_token
    self.token ||= Time.now.to_f.to_s.gsub(".", "")[0..12].to_i
  end

# prepare timeslots
  def refactor_time
    @year = date_completed.year.to_i
    @month = date_completed.month.to_i
    @day = date_completed.day.to_i
    @datetime_completed_new = datetime_completed.change(year:@year, month:@month, day:@day)
    self.assign_attributes(:datetime_completed => @datetime_completed_new)

    @year_2 = date_awarded.year.to_i
    @month_2 = date_awarded.month.to_i
    @day_2 = date_awarded.day.to_i
    @datetime_awarded_new = datetime_awarded.change(year:@year_2, month:@month_2, day:@day_2)
    self.assign_attributes(:datetime_awarded => @datetime_awarded_new)
  end

  def remove_special_characters
    tag.gsub!(/[^0-9A-Za-z]/, '')
  end

  def search_data
    attributes.merge(
      title: title,
      description: description,
      tag: tag.collect{ |t| Category.find(t).name},
      locations_road_names: locations.map(&:road_name)
    )
  end

  def create_conversation
    if Conversation.between(organizer_id, Rsvp.find_by_id(awardee_id).attendee_id).blank?
      Conversation.create(sender_id: organizer_id, recipient_id: Rsvp.find_by_id(awardee_id).attendee_id, timezone_offset: timezone_offset)
    end
  end

  def transfer_bounty_to_solver
    @winning_bid = Rsvp.find(awardee_id)
    @solver_wallet = User.find(@winning_bid.attendee_id).wallet
    @amount = @winning_bid.bid
    @transaction = @solver_wallet.transactions.create(transaction_type: 1, amount: @amount, lesson_id: id)
    @solver_wallet.update_wallet_balance(@transaction)
  end

  def award_bid_push
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "Congrats! You got the job!",
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(self)
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

  def award_bid_notification
    @bid = Rsvp.find(awardee_id)
    BidMailer.award_bid_email(self, @bid).deliver
    self.award_bid_push
  end

  def completed_job_push
    @solver = Rsvp.find(awardee_id).attendee
    @owner = self.organizer
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "#{@solver.first_name} has completed the job!",
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(self)
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

  def completed_job_notification
    if solver_agree_cancel.nil?
      @bid = Rsvp.find(awardee_id)
      BidMailer.completed_job_email(self, @bid).deliver
      self.completed_job_push
    end
  end

  def verified_job_push
    @owner = self.organizer
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "#{@owner.first_name} has verified the job completion!",
      data: {
        url: Rails.application.routes.url_helpers.lesson_url(self)
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

  def owner_cancel_job_notification
    BidMailer.owner_cancel_job_email(self).deliver
    self.owner_cancel_push
  end

  def owner_cancel_push
    @owner = self.organizer
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "#{@owner.first_name} has requested to cancel the job.",
      data: {
        url: Rails.application.routes.url_helpers.lesson_solver_url
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

  def solver_cancel_job_actions
    self.pass_to_solver_completed_problems
    self.update_column(:job_completed_datetime, DateTime.current)
    self.solver_cancel_job_notification
  end

  def solver_cancel_job_notification
    BidMailer.solver_cancel_job_email(self).deliver
    self.solver_cancel_push
  end

  def solver_cancel_push
    @solver = Rsvp.find(awardee_id).attendee
    @owner = self.organizer
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "#{@solver.first_name} is unable to complete the job.",
      data: {
        url: Rails.application.routes.url_helpers.lesson_owner_url
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

  def verified_job_notification
    @bid = Rsvp.find(awardee_id)
    BidMailer.verified_job_email(self, @bid).deliver
    self.verified_job_push
  end

  def changes_to_job_push
    @owner = self.organizer
    @bids = self.rsvps
    @bids.each do |bid|
      @endpoint = bid.attendee.endpoint
      @p256dh = bid.attendee.p256dh
      @auth = bid.attendee.auth
      @message = {
        title: title,
        body: "There are some changes to the job. Please check the posting.",
        data: {
          url: Rails.application.routes.url_helpers.lesson_url(self)
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

  def changes_to_job_notification
    @changes = changes
    puts @changes
    if self.rsvps.present?
      self.send_changes_to_job_email(@changes)
      self.changes_to_job_push
      puts 'hahe'
    end
  end

  def send_changes_to_job_email(changes_attr)
    @changes = changes_attr
    BidMailer.changes_to_job_email(self, @changes).deliver
  end

  def update_bounty_received_datetime
    self.update_attribute(:bounty_received_datetime, DateTime.current)
  end

  def solver_responds_cancel
    if solver_agree_cancel == true
      self.pass_to_owner_completed_problems
      self.pass_to_solver_completed_problems
      self.update_column(:job_completed_datetime, DateTime.current)
      @winning_bid = Rsvp.find(awardee_id)
      @owner_wallet = User.find(self.organizer).wallet
      @amount = @winning_bid.bid
      @transaction = @owner_wallet.transactions.create(transaction_type: 3, amount: @amount, lesson_id: id)
      self.update_column(:refund_bounty_tx_id, @transaction.id)
      @owner_wallet.update_wallet_balance(@transaction)
      self.solver_agree_cancel_notification
    else
      self.solver_disagree_cancel_notification
    end
  end

  def solver_agree_cancel_notification
    BidMailer.solver_agree_cancel_email(self).deliver
    self.solver_agree_cancel_push
  end

  def solver_agree_cancel_push
    @solver = Rsvp.find(awardee_id).attendee
    @owner = self.organizer
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "#{@solver.first_name} has agreed to cancel the job.",
      data: {
        url: Rails.application.routes.url_helpers.lesson_owner_url
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

  def owner_responds_cancel
    if owner_agree_cancel == true
      self.pass_to_owner_completed_problems
      self.pass_to_solver_completed_problems
      self.update_column(:job_completed_datetime, DateTime.current)
      @winning_bid = Rsvp.find(awardee_id)
      @owner_wallet = User.find(self.organizer).wallet
      @amount = @winning_bid.bid
      @transaction = @owner_wallet.transactions.create(transaction_type: 3, amount: @amount, lesson_id: id)
      self.update_column(:refund_bounty_tx_id, @transaction.id)
      @owner_wallet.update_wallet_balance(@transaction)
    else
      self.owner_disagree_cancel_notification
    end
  end

  def owner_agree_cancel_notification
    BidMailer.owner_agree_cancel_email(self).deliver
    self.owner_agree_cancel_push
  end

  def owner_agree_cancel_push
    @solver = Rsvp.find(awardee_id).attendee
    @owner = self.organizer
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "#{@owner.first_name} has agreed to cancel the job.",
      data: {
        url: Rails.application.routes.url_helpers.lesson_solver_url
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

  handle_asynchronously :award_bid_notification, :run_at => Time.now
  handle_asynchronously :completed_job_notification, :run_at => Time.now
  handle_asynchronously :verified_job_notification, :run_at => Time.now
  handle_asynchronously :send_changes_to_job_email, :run_at => Time.now
  handle_asynchronously :owner_agree_cancel_notification, :run_at => Time.now
  handle_asynchronously :solver_agree_cancel_notification, :run_at => Time.now
  handle_asynchronously :solver_cancel_job_notification, :run_at => Time.now
  handle_asynchronously :owner_cancel_job_notification, :run_at => Time.now
end
