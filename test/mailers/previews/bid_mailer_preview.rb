# Preview all emails at http://localhost:3000/rails/mailers/bid_mailer
class BidMailerPreview < ActionMailer::Preview
  def receive_bid_email_preview
    BidMailer.receive_bid_email(Lesson.last, Rsvp.last)
  end

  def award_bid_email_preview
    BidMailer.award_bid_email(Lesson.last, Rsvp.last)
  end

  def changes_to_job_email_preview
    @changes = {'tilte' => ['test1', 'test2']}
    BidMailer.changes_to_job_email(Lesson.last, @changes, ["wilsonwan88@gmail.com"])
  end

  def completed_job_email_preview
    BidMailer.completed_job_email(Lesson.last, Rsvp.last)
  end

  def verified_job_email_preview
    BidMailer.verified_job_email(Lesson.last, Rsvp.last)
  end

  def new_question_email_preview
    BidMailer.new_question_email(Question.last)
  end

  def new_answer_email_preview
    BidMailer.new_answer_email(Answer.last)
  end

  def owner_cancel_job_email_preview
    BidMailer.owner_cancel_job_email(Lesson.last)
  end

  def solver_cancel_job_email_preview
    BidMailer.solver_cancel_job_email(Lesson.last)
  end

  def solver_agree_cancel_email_preview
    BidMailer.solver_agree_cancel_email(Lesson.last, Rsvp.last)
  end

  def job_repost_email_preview
    BidMailer.job_repost_email(Lesson.last, Lesson.last)
  end

  def solver_reports_incident_email_preview
    BidMailer.solver_reports_incident_email(Lesson.last)
  end

  def solver_reports_owner_reports_email_preview
    BidMailer.solver_report_owner_report_email(Lesson.last)
  end

  def owner_reports_email_preview
    BidMailer.owner_report_email(Lesson.last)
  end

  def owner_cancel_solver_report_email_preview
    BidMailer.owner_cancel_solver_report_email(Lesson.last)
  end

  def owner_cancel_auto_refund_owner_email_preview
    BidMailer.owner_cancel_auto_refund_owner_email(Lesson.last, Rsvp.last)
  end

  def owner_cancel_auto_refund_solver_email_preview
    BidMailer.owner_cancel_auto_refund_solver_email(Lesson.last, Rsvp.last)
  end

  def solver_auto_refund_owner_email_preview
    BidMailer.solver_auto_refund_owner_email(Lesson.last, Rsvp.last)
  end

  def solver_auto_refund_solver_email_preview
    BidMailer.solver_auto_refund_solver_email(Lesson.last, Rsvp.last)
  end
end
