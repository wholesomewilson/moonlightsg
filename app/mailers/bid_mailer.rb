class BidMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def receive_bid_email(lesson, bid)
    @lesson = lesson
    @owner = @lesson.organizer
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @bidder = User.find(@bid.attendee_id)
    mail(to: @owner.email, subject: "There is a new bid! :) - #{@bid_amount} for #{@lesson.title}")
  end

  def award_bid_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @bidder = User.find(@bid.attendee_id)
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
    @solver = User.find(@bid.attendee_id)
    @owner = User.find(@lesson.organizer_id)
    mail(to: @owner.email, subject: "[Attention Required] #{@solver.first_name} has completed #{@lesson.title}!")
  end

  def verified_job_email(lesson, bid)
    @lesson = lesson
    @bid = bid
    @bid_amount = view_context.number_to_currency(@bid.bid)
    @solver = User.find(@bid.attendee_id)
    @owner = User.find(@lesson.organizer_id)
    mail(to: @solver.email, subject: "Congrats! #{@owner.first_name} has verified that the job is completed!")
  end
end
