class BidMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def receive_bid_email(lesson, bid)
    @lesson = lesson
    @owner = @lesson.organizer
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @bidder = @bid.attendee
    @recipient = @owner
    mail(to: @owner.email, subject: "There is a new bid! :) - #{@bid_amount} for #{@lesson.title}")
  end

  def award_bid_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @bidder = @bid.attendee
    @recipient = @bidder
    mail(to: @bidder.email, subject: "Congrats! You got the job! - #{@lesson.title}!")
  end

  def changes_to_job_email(lesson, changes)
    @lesson = lesson
    @changes = changes
    @changes.delete('date_completed')
    @emails = @lesson.rsvps.map {|rsvp| rsvp.attendee.email }
    mail(to: @emails, subject: "[Attention Required] Changes to #{@lesson.title}")
  end

  def completed_job_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @solver = @bid.attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, subject: "[Attention Required] #{@solver.first_name} has completed #{@lesson.title}!")
  end

  def verified_job_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = @bid.attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, subject: "Congrats! #{@owner.first_name} has verified that the job is completed!")
  end

  def new_question_email(question)
    @question = question
    @lesson = @question.lesson
    @solver = User.find(@question.user_id)
    @owner = @lesson.organizer_id
    @recipient = @owner
    mail(to: @owner.email, subject: "[Attention Required] #{@solver.first_name} has a question for #{@lesson.title}.")
  end

  def new_answer_email(answer)
    @answer = answer
    @question = @answer.question
    @lesson = @question.lesson
    @solver = User.find(@question.user_id)
    @owner = @lesson.organizer_id
    @recipient = @solver
    mail(to: @solver.email, subject: "Great! #{@owner.first_name} answered your question for #{@lesson.title}.")
  end

  def owner_cancel_job_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, subject: "Oh no. #{@owner.first_name} has requested to cancel #{@lesson.title}.")
  end

  def solver_cancel_job_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, subject: "Oh no. #{@solver.first_name} has requested to cancel #{@lesson.title}.")
  end

  def solver_agree_cancel_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, subject: "Yes! #{@solver.first_name} has agreed to cancel #{@lesson.title}.")
  end

  def owner_agree_cancel_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, subject: "Yes! #{@owner.first_name} has agreed to cancel #{@lesson.title}.")
  end

  def solver_disagree_cancel_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, subject: "Oh no, #{@solver.first_name} has disagreed to cancel #{@lesson.title}.")
  end

  def owner_disagree_cancel_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, subject: "Oh no, #{@owner.first_name} has agreed to cancel #{@lesson.title}.")
  end
end
