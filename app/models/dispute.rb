class Dispute < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :user
  after_create :update_raise_a_dispute
  after_create :solver_reports_action, if: ->(obj){ obj.user_id != Lesson.find(obj.lesson_id).organizer_id }
  after_create :owner_reports_action, if: ->(obj){ obj.user_id == Lesson.find(obj.lesson_id).organizer_id }

  def update_raise_a_dispute
    if user_id == self.lesson.organizer_id
      self.lesson.update_attribute(:raise_a_dispute_sponsor, DateTime.current)
    else
      self.lesson.update_attribute(:raise_a_dispute_hunter, DateTime.current)
    end
  end

  def solver_reports_action
    @lesson = self.lesson
    @owner = @lesson.organizer
    if @lesson.disputes.map { |x| x.user}.include? @owner
      @lesson.owner_report_solver_report_actions
    else
      @lesson.solver_auto_refund_actions
    end
  end

  def owner_reports_action
    @lesson = self.lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    if @lesson.solver_cancel_job.blank?
      if @lesson.disputes.map { |x| x.user}.include? @solver
        @lesson.solver_report_owner_report_actions
      else
        @lesson.owner_report_actions
      end
    end
  end

end
