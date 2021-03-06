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
    if @lesson.raise_a_dispute_sponsor.present? and @lesson.owner_cancel_job.present?
      @lesson.owner_report_solver_report_actions
    elsif @lesson.raise_a_dispute_sponsor.present? and @lesson.owner_cancel_job.blank?
      @lesson.owner_report_solver_report_actions
    elsif @lesson.raise_a_dispute_sponsor.blank? and @lesson.owner_cancel_job.present?
      @lesson.owner_cancel_solver_report_actions
    else
      @lesson.solver_auto_refund_actions
    end
  end

  def owner_reports_action
    @lesson = self.lesson
    if @lesson.raise_a_dispute_hunter.present?
      @lesson.solver_report_owner_report_actions
    else
      @lesson.owner_report_actions
    end
  end

end
