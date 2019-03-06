class Dispute < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :user
  after_create :update_raise_a_dispute
  after_create :solver_reports_action, if: ->(obj){ obj.user_id != Lesson.find(obj.lesson_id).organizer_id }
  after_create :owner_reports_action, if: ->(obj){ obj.user_id == Lesson.find(obj.lesson_id).organizer_id }

  def update_raise_a_dispute
    self.lesson.update_attribute(:raise_a_dispute, DateTime.current)
  end

  def solver_reports_action
    if self.lesson.owner_cancel_job.present?
      self.lesson.owner_cancel_solver_report_actions
    else
      self.lesson.solver_auto_refund_actions
    end
  end

  def owner_reports_action
    @lesson = Lesson.find(lesson_id)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    if @lesson.disputes.map { |x| x.user}.include? @solver
      @lesson.solver_report_owner_report_actions
    end
  end
end
