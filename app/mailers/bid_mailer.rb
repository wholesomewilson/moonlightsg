class BidMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def receive_bid_email(lesson, bid)
    @lesson = lesson
    @owner = @lesson.organizer
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @bidder = @bid.attendee
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "There is a new bid! :) - #{@bid_amount} for #{@lesson.title}")
  end

  def award_bid_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @customer = @lesson.organizer
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @bidder = @bid.attendee
    @recipient = @bidder
    mail(to: @bidder.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Hooray! #{@customer.first_name} awarded the job to you! - #{@lesson.title}!")
  end

  def changes_to_job_email(lesson, changes, emails)
    @lesson = lesson
    @changes = changes
    @changes.delete('date_completed')
    @changes.delete('updated_at')
    @emails = emails
    mail(to: @emails, from: "Moonlight <notifications@moonlight.sg>", subject: "[Attention Required] Changes to #{@lesson.title}")
  end

  def completed_job_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @solver = @bid.attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "[Attention Required] #{@solver.first_name} has completed #{@lesson.title}!")
  end

  def verified_job_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = @bid.attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Hooray! #{@owner.first_name} has verified that the job is completed!")
  end

  def new_question_email(question)
    @question = question
    @lesson = @question.lesson
    @solver = User.find(@question.user_id)
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "[Attention Required] #{@solver.first_name} has a question for #{@lesson.title}.")
  end

  def new_answer_email(answer)
    @answer = answer
    @question = @answer.question
    @lesson = @question.lesson
    @solver = User.find(@question.user_id)
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Great! #{@owner.first_name} answered your question for #{@lesson.title}.")
  end

  def owner_cancel_job_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Oh no. #{@owner.first_name} has requested to cancel #{@lesson.title}.")
  end

  def solver_cancel_job_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Oh no. #{@solver.first_name} has cancelled #{@lesson.title}.")
  end

  def solver_agree_cancel_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    if @lesson.deposit.present?
      @deposit_amount = view_context.number_to_currency(@lesson.deposit)
    end
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "Yes! #{@solver.first_name} has agreed to cancel #{@lesson.title}.")
  end

  def job_repost_email(old_lesson, new_lesson)
    @lesson = new_lesson
    @owner = @lesson.organizer
    @emails = old_lesson.rsvps.map { |rsvp| rsvp.attendee.email }
    mail(to: @emails, from: "Moonlight <notifications@moonlight.sg>", subject: "#{@owner.first_name} has reposted #{@lesson.title}!")
  end

  def solver_reports_incident_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight@gmail.com', subject: "Oh no, #{@solver.first_name} has reported an incident for #{@lesson.title}.")
  end

  def solver_report_owner_report_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight@gmail.com', subject: "Oh no, #{@owner.first_name} has reported an incident for #{@lesson.title}.")
  end

  def owner_report_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight@gmail.com', subject: "Oh no, #{@owner.first_name} has reported an incident for #{@lesson.title}.")
  end

  def owner_cancel_solver_report_email(lesson)
    @lesson = lesson
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight@gmail.com', subject: "Oh no, #{@solver.first_name} has reported an incident #{@lesson.title}.")
  end

  def owner_cancel_auto_refund_owner_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "We have refunded #{@bid_amount} to your wallet for #{@lesson.title}.")
  end

  def owner_cancel_auto_refund_solver_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", subject: "We have refunded #{@bid_amount} to #{@owner.first_name} for #{@lesson.title}.")
  end

  def solver_auto_refund_owner_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight@gmail.com', subject: "We have paid #{@bid_amount} to #{@solver.first_name} for #{@lesson.title}.")
  end

  def solver_auto_refund_solver_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @owner = @lesson.organizer
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", bcc: 'hootemoonlight@gmail.com', subject: "We have paid #{@bid_amount} to your wallet for #{@lesson.title}.")
  end

  def partial_refund_bounty_customer_email(lesson, amount)
    @lesson = lesson
    @bid_amount = view_context.number_to_currency(amount)
    @owner = @lesson.organizer
    @recipient = @owner
    mail(to: @owner.email, from: "Moonlight <notifications@moonlight.sg>", subject: "We have made a partial refund of #{@bid_amount} to your wallet for #{@lesson.title}.")
  end

  def partial_refund_bounty_shopper_email(lesson, amount)
    @lesson = lesson
    @bid_amount = view_context.number_to_currency(amount)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    @recipient = @solver
    mail(to: @solver.email, from: "Moonlight <notifications@moonlight.sg>", subject: "We have made a partial payment of #{@bid_amount} to your wallet for #{@lesson.title}.")
  end
end
