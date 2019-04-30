class Rsvp < ActiveRecord::Base
  belongs_to :attended_lesson, class_name: "Lesson"
  belongs_to :attendee, class_name: "User"
  has_many :guests, dependent: :destroy
  accepts_nested_attributes_for :guests, reject_if: :all_blank

  after_create :receive_bid_notification
  before_destroy :remove_from_solvers

  #Success Notification

  def remove_from_solvers
    self.attendee.remove_from_ongoing_and_completed(attended_lesson_id)
  end

  def receive_bid_notification
    @lesson = Lesson.find(attended_lesson_id)
    BidMailer.receive_bid_email(@lesson, self).deliver
  end

  handle_asynchronously :receive_bid_notification, :run_at => Time.now
end
