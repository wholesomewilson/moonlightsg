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
    BidMailer.changes_to_job_email(Lesson.last, @changes)
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
end
