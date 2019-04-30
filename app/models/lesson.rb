class Lesson < ActiveRecord::Base

before_destroy :close_conversation, if: -> {awardee_id.present?}
before_destroy :remove_from_users
# Association
belongs_to :organizer, class_name: "User"
has_and_belongs_to_many :categories
has_and_belongs_to_many :bountytypes
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

#Trigger actions after Job is created
after_create :pass_to_owner_ongoing_problems

after_update :pass_to_solver_ongoing_problems, if: -> {awardee_id_changed? && awardee_id.present?}
after_update :create_conversation, if: -> {awardee_id_changed? && awardee_id.present?}
after_update :award_bid_notification, if: -> {awardee_id_changed? && awardee_id.present? && bounty_received_datetime.present?}

#Trigger actions after Job is completed
after_update :completed_job_notification, if: -> {job_completed_datetime_changed? && job_completed_datetime.present? && raise_a_dispute_sponsor.blank? && raise_a_dispute_hunter.blank?}

#Trigger actions after Job is Verified
after_update :pass_to_owner_completed_problems, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :pass_to_solver_completed_problems, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :close_conversation, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :verified_job_notification, if: -> {job_verified_datetime_changed? && job_verified_datetime.present?}
after_update :transfer_bounty_to_solver, if: -> {job_verified_datetime_changed? && bounty_received_datetime.present?}

#Trigger actions after Job is cancelled
after_update :owner_cancel_job_actions, if: -> {owner_cancel_job_changed? && owner_cancel_job.present? && raise_a_dispute_sponsor.blank? && raise_a_dispute_hunter.blank?}
after_update :solver_cancel_job_actions, if: -> {solver_cancel_job_changed? && solver_cancel_job.present? && raise_a_dispute_hunter.blank? && raise_a_dispute_sponsor.blank?}
after_update :solver_responds_cancel, if: -> {solver_agree_cancel_changed? && solver_agree_cancel.present?}
after_update :owner_responds_cancel, if: -> {owner_agree_cancel_changed? && owner_agree_cancel.present?}

#Update deposit to nil if bounty_type is not 2
before_update :update_deposit_to_nil, if: -> {bounty_type_changed?}

#Trigger actions after Job is changes
before_update :changes_to_job_notification, if: -> (obj){ (obj.deposit_changed? || obj.bounty_type_changed? || obj.bounty_changed? || obj.title_changed? || obj.datetime_completed_changed? || obj.contact_no_changed? || obj.description_changed?) && obj.awardee_id.blank? }

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

  def repost_lesson_actions
    if solver_cancel_job.present?
      Rsvp.find(awardee_id).update_attribute(:bid_withdraw, DateTime.current)
    end
    Rsvp.find(awardee_id).attendee.remove_from_completed_solver(id)
    self.update_column(:awardee_id, nil)
    self.update_column(:owner_cancel_job, nil)
    self.update_column(:solver_cancel_job, nil)
    self.update_column(:solver_agree_cancel, nil)
    self.update_column(:raise_a_dispute, nil)
    self.update_column(:dispute_details, nil)
    self.organizer.add_to_ongoing_problems_owner(id)
    self.organizer.remove_from_completed_owner(id)
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
    if Rsvp.find_by_id(awardee_id).present?
      @conversation = Conversation.where(sender_id: organizer_id).where(recipient_id: Rsvp.find_by_id(awardee_id).attendee_id)
      if !(self.organizer.ongoing_problems_owner & Rsvp.find_by_id(awardee_id).attendee.ongoing_problems_solver).any?
        if @conversation.first.message_notification_job_id.present?
          Delayed::Job.find(message_notification_job_id).destroy
        end
        Conversation.destroy(@conversation.first.id)
      end
    end
  end

  def remove_from_users
    self.organizer.remove_from_ongoing_and_completed(id)
    if awardee_id
      if Rsvp.find_by_id(awardee_id).present?
        Rsvp.find_by_id(awardee_id).attendee.remove_from_ongoing_and_completed(id)
      end
    end
  end

  def remove_from_owner
    self.organizer.remove_from_ongoing_and_completed(id)
  end

  def remove_from_owner_completed
    self.organizer.remove_from_ongoing_and_completed(id)
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
    if bounty_type == 2
      @amount_bef_fee = @winning_bid.bid + deposit
    else
      @amount_bef_fee = @winning_bid.bid
    end
    @fee = self.get_fee(@amount_bef_fee)
    @transaction_bounty = @solver_wallet.transactions.create(transaction_type: 1, amount: @amount_bef_fee, lesson_id: id)
    @transaction_fee = @solver_wallet.transactions.create(transaction_type: 0, amount: @fee, lesson_id: id)
    @solver_wallet.update_wallet_balance(@transaction_bounty)
    @solver_wallet.update_wallet_balance(@transaction_fee)
    User.first.wallet.update_wallet_balance(@transaction_fee)
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
    #self.award_bid_push
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
      #self.completed_job_push
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

  def auto_refund_time
    DateTime.current + 72.hours
  end

  def owner_cancel_job_actions
    @job = self.delay(:run_at => auto_refund_time).owner_cancel_auto_refund
    self.update_column(:owner_auto_refund_job_id, @job.id)
    self.owner_cancel_job_notification
  end

  def owner_cancel_auto_refund
    self.pass_to_owner_completed_problems
    self.pass_to_solver_completed_problems
    self.update_column(:job_completed_datetime, DateTime.current)
    @winning_bid = Rsvp.find(awardee_id)
    @owner_wallet = User.find(self.organizer_id).wallet
    if bounty_type == 2
      @amount = @winning_bid.bid + deposit
    else
      @amount = @winning_bid.bid
    end
    @transaction = @owner_wallet.transactions.create(transaction_type: 4, amount: @amount, lesson_id: id)
    self.update_column(:refund_bounty_tx_id, @transaction.id)
    @owner_wallet.update_wallet_balance(@transaction)
    self.close_conversation
    self.owner_cancel_auto_refund_notification
  end

  def owner_cancel_auto_refund_notification
    @bid = Rsvp.find(awardee_id)
    BidMailer.owner_cancel_auto_refund_owner_email(self, @bid).deliver
    BidMailer.owner_cancel_auto_refund_solver_email(self, @bid).deliver
    #self.owner_cancel_auto_refund_push_to_owner
    #self.owner_cancel_auto_refund_push_to_solver
  end

  def owner_cancel_auto_refund_push_to_owner
    @owner = self.organizer
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "We have refunded the bounty to your wallet",
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

  def owner_cancel_auto_refund_push_to_solver
    @owner = self.organizer
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "We have refunded the bounty to #{@owner.first_name}",
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

  def solver_auto_refund_actions
    @job = self.delay(:run_at => auto_refund_time).solver_auto_refund
    self.update_column(:solver_auto_refund_job_id, @job.id)
    self.solver_reports_incident_notification
  end

  def solver_auto_refund
    self.pass_to_owner_completed_problems
    self.pass_to_solver_completed_problems
    self.update_column(:job_completed_datetime, DateTime.current)
    @winning_bid = Rsvp.find(awardee_id)
    @solver_wallet = User.find(@winning_bid.attendee_id).wallet
    if bounty_type == 2
      @amount_bef_fee = @winning_bid.bid + deposit
    else
      @amount_bef_fee = @winning_bid.bid
    end
    @fee = self.get_fee(@amount_bef_fee)
    @transaction_bounty = @solver_wallet.transactions.create(transaction_type: 5, amount: @amount_bef_fee, lesson_id: id)
    @transaction_fee = @solver_wallet.transactions.create(transaction_type: 0, amount: @fee, lesson_id: id)
    self.update_column(:refund_bounty_tx_id, @transaction_bounty.id)
    @solver_wallet.update_wallet_balance(@transaction_bounty)
    @solver_wallet.update_wallet_balance(@transaction_fee)
    User.first.wallet.update_wallet_balance(@transaction_fee)
    self.close_conversation
    self.solver_auto_refund_notification
  end

  def solver_auto_refund_notification
    @bid = Rsvp.find(awardee_id)
    BidMailer.solver_auto_refund_owner_email(self, @bid).deliver
    BidMailer.solver_auto_refund_solver_email(self, @bid).deliver
    #self.solver_auto_refund_push_to_owner
    #self.solver_auto_refund_push_to_solver
  end

  def solver_auto_refund_push_to_owner
    @owner = self.organizer
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "We have paid the bounty to #{@solver.first_name}.",
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

  def solver_auto_refund_push_to_solver
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "We have paid the bounty to your wallet!",
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

  def solver_reports_incident_notification
    BidMailer.solver_reports_incident_email(self).deliver
    #self.owner_cancel_solver_report_push
  end

  def owner_cancel_job_notification
    BidMailer.owner_cancel_job_email(self).deliver
    #self.owner_cancel_push
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
    self.pass_to_owner_completed_problems
    self.update_column(:job_completed_datetime, DateTime.current)
    @winning_bid = Rsvp.find(awardee_id)
    @owner_wallet = User.find(self.organizer_id).wallet
    if bounty_type == 2
      @amount = @winning_bid.bid + deposit
    else
      @amount = @winning_bid.bid
    end
    @transaction = @owner_wallet.transactions.create(transaction_type: 4, amount: @amount, lesson_id: id)
    self.update_column(:refund_bounty_tx_id, @transaction.id)
    @owner_wallet.update_wallet_balance(@transaction)
    self.close_conversation
    self.solver_cancel_job_notification
  end

  def solver_cancel_job_notification
    BidMailer.solver_cancel_job_email(self).deliver
    #self.solver_cancel_push
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
    #self.verified_job_push
  end

  def changes_to_job_push(bidders)
    @owner = self.organizer
    @bidders = bidders
    @bidders.each do |bidder|
      @endpoint = bidder.endpoint
      @p256dh = bidder.p256dh
      @auth = bidder.auth
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
    if self.rsvps.count >= 1
      @emails = self.rsvps.map {|rsvp| rsvp.attendee.email}
      @bidders = self.rsvps.map {|rsvp| rsvp.attendee}
      self.send_changes_to_job_email(@emails, changes)
      #self.changes_to_job_push(@bidders)
      self.rsvps.destroy_all
    end
  end

  def send_changes_to_job_email(emails, changes_attr)
    @changes = changes_attr
    @emails = emails
    BidMailer.changes_to_job_email(self, @changes, @emails).deliver
  end

  def update_bounty_received_datetime
    self.update_attribute(:bounty_received_datetime, DateTime.current)
  end

  def solver_responds_cancel
    Delayed::Job.find(owner_auto_refund_job_id).destroy
    self.update_column(:owner_auto_refund_job_id, nil)
    self.pass_to_owner_completed_problems
    self.pass_to_solver_completed_problems
    self.update_column(:job_completed_datetime, DateTime.current)
    @winning_bid = Rsvp.find(awardee_id)
    @owner_wallet = User.find(self.organizer_id).wallet
    if bounty_type == 2
      @amount = @winning_bid.bid + deposit
    else
      @amount = @winning_bid.bid
    end
    @transaction = @owner_wallet.transactions.create(transaction_type: 4, amount: @amount, lesson_id: id)
    self.update_column(:refund_bounty_tx_id, @transaction.id)
    @owner_wallet.update_wallet_balance(@transaction)
    self.close_conversation
    self.solver_agree_cancel_notification
  end

  def solver_agree_cancel_notification
    @bid = Rsvp.find(awardee_id)
    BidMailer.solver_agree_cancel_email(self, @bid).deliver
    #self.solver_agree_cancel_push
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

  def update_rsvps_id(new_id)
    @rsvps = self.rsvps
    @rsvps.each { |rsvp| rsvp.update_attribute(:attended_lesson_id, new_id) }
  end

  def job_repost_notification(new_lesson)
    BidMailer.job_repost_email(self, new_lesson).deliver
    #self.job_repost_push(new_lesson)
  end

  def job_repost_push(new_lesson)
    @owner = self.organizer
    @old_bids = self.rsvps
    @old_bids.each do |bid|
      @endpoint = bid.attendee.endpoint
      @p256dh = bid.attendee.p256dh
      @auth = bid.attendee.auth
      @message = {
        title: title,
        body: "#{@owner.first_name} has reposted the job. If you're keen, please place a bid!",
        data: {
          url: Rails.application.routes.url_helpers.lesson_url(new_lesson)
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

  def owner_cancel_solver_report_actions
    Delayed::Job.find(owner_auto_refund_job_id).destroy
    self.update_column(:owner_auto_refund_job_id, nil)
    @job = self.delay(:run_at => auto_refund_time).solver_auto_refund
    self.update_column(:solver_auto_refund_job_id, @job.id)
    self.solver_reports_incident_notification
  end

  def owner_report_solver_report_actions
    Delayed::Job.find(owner_auto_refund_job_id).destroy
    self.update_column(:owner_auto_refund_job_id, nil)
    self.owner_cancel_solver_report_notifications
  end

  def owner_cancel_solver_report_notifications
    BidMailer.owner_cancel_solver_report_email(self).deliver
    #self.owner_cancel_solver_report_push
  end

  def owner_cancel_solver_report_push
    @solver = Rsvp.find(awardee_id).attendee
    @owner = self.organizer
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "#{@solver.first_name} has reported an incident for this job",
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

  def solver_report_owner_report_actions
    Delayed::Job.find(solver_auto_refund_job_id).destroy
    self.update_column(:solver_auto_refund_job_id, nil)
    self.solver_report_owner_report_notifications
  end

  def solver_report_owner_report_notifications
    BidMailer.solver_report_owner_report_email(self).deliver
    #self.owner_report_push
  end

  def owner_report_actions
    if owner_auto_refund_job_id.blank? && refund_bounty_tx_id.blank?
      @job = self.delay(:run_at => auto_refund_time).owner_cancel_auto_refund
      self.update_column(:owner_auto_refund_job_id, @job.id)
      self.owner_report_notifications
    end
  end

  def owner_report_notifications
    BidMailer.owner_report_email(self).deliver
    #self.owner_report_push
  end

  def owner_report_push
    @solver = Rsvp.find(awardee_id).attendee
    @owner = self.organizer
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "#{@owner.first_name} has reported an incident for this job",
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

  def update_deposit_to_nil
    if bounty_type != 2
      self.update_column(:deposit, nil)
    end
  end

  def get_fee(amount)
    if bounty_received_method == 1 || bounty_received_method == 3
      @fee = 0.02
    else
      @fee = 0.09 if amount >= 10 && amount < 15
      @fee = 0.07 if amount >= 15 && amount < 20
      @fee = 0.06 if amount >= 20 && amount < 40
      @fee = 0.05 if amount >= 40 && amount < 90
      @fee = 0.04 if amount >= 90
    end
    return (amount * @fee).round(2)
  end

  def partial_refund_bounty_actions(amount_sponsor, amount_hunter)
    self.pass_to_owner_completed_problems
    self.pass_to_solver_completed_problems
    self.update_column(:job_completed_datetime, DateTime.current)
    @winning_bid = Rsvp.find(awardee_id)
    @amount_bef_fee = @winning_bid.bid
    @owner = self.organizer
    @solver = @winning_bid.attendee
    @transaction_owner = @owner.wallet.transactions.create(transaction_type: 6, amount: amount_sponsor, lesson_id: id) # 6 = partial refund
    @owner.wallet.update_wallet_balance(@transaction_owner)
    @fee = self.get_fee(@amount_bef_fee)
    @transaction_bounty = @solver.wallet.transactions.create(transaction_type: 6, amount: amount_hunter, lesson_id: id)
    @transaction_fee = @solver.wallet.transactions.create(transaction_type: 0, amount: @fee, lesson_id: id)
    @solver.wallet.update_wallet_balance(@transaction_bounty)
    @solver.wallet.update_wallet_balance(@transaction_fee)
    User.first.wallet.update_wallet_balance(@transaction_fee)
    self.update_column(:refund_bounty_tx_id, @transaction_owner.id)
    self.close_conversation
    self.partial_refund_bounty_notifications(amount_sponsor, amount_hunter)
  end

  def partial_refund_bounty_notifications(amount_sponsor, amount_hunter)
    BidMailer.partial_refund_bounty_customer_email(self, amount_sponsor).deliver
    BidMailer.partial_refund_bounty_shopper_email(self, amount_hunter).deliver
    #self.partial_refund_bounty_customer_push
    #self.partial_refund_bounty_shopper_push
  end

  def partial_refund_bounty_customer_push
    @owner = self.organizer
    @endpoint = @owner.endpoint
    @p256dh = @owner.p256dh
    @auth = @owner.auth
    @message = {
      title: title,
      body: "We have made a partial refund to your wallet",
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

  def partial_refund_bounty_shopper_push
    @solver = Rsvp.find(awardee_id).attendee
    @endpoint = @solver.endpoint
    @p256dh = @solver.p256dh
    @auth = @solver.auth
    @message = {
      title: title,
      body: "We have made a partial payment to your wallet",
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

  def pay_now_verified
    @winning_bid = Rsvp.find(awardee_id)
    @bid_amount = @winning_bid.bid
    @deduct_tx = Transaction.where(lesson_id: self.id).where(transaction_type: 7).first
    if self.deposit.present?
      @bounty = @bid_amount + self.deposit
      @bounty = @bounty - @deduct_tx.amount if @deduct_tx.present?
    else
      @bounty = @bid_amount
      @bounty = @bounty - @deduct_tx.amount if @deduct_tx.present?
    end
    BidMailer.pay_now_verified_email(self, @winning_bid, @bounty).deliver
  end

  handle_asynchronously :award_bid_notification, :run_at => Time.now
  handle_asynchronously :completed_job_notification, :run_at => Time.now
  handle_asynchronously :verified_job_notification, :run_at => Time.now
  handle_asynchronously :send_changes_to_job_email, :run_at => Time.now
  handle_asynchronously :changes_to_job_push, :run_at => Time.now
  handle_asynchronously :solver_agree_cancel_notification, :run_at => Time.now
  handle_asynchronously :solver_cancel_job_notification, :run_at => Time.now
  handle_asynchronously :owner_cancel_job_notification, :run_at => Time.now
  handle_asynchronously :job_repost_notification, :run_at => Time.now
  handle_asynchronously :owner_cancel_auto_refund_notification, :run_at => Time.now
  handle_asynchronously :solver_auto_refund_notification, :run_at => Time.now
  handle_asynchronously :owner_cancel_solver_report_push, :run_at => Time.now
  handle_asynchronously :owner_cancel_solver_report_notifications, :run_at => Time.now
  handle_asynchronously :solver_reports_incident_notification, :run_at => Time.now
  handle_asynchronously :solver_report_owner_report_notifications, :run_at => Time.now
  handle_asynchronously :owner_report_notifications, :run_at => Time.now
  handle_asynchronously :partial_refund_bounty_notifications, :run_at => Time.now
  handle_asynchronously :pay_now_verified, :run_at => Time.now
end
