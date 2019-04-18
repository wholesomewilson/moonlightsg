class DisputesController < ApplicationController
  before_filter :authorize_admin, only: [:index]
  include DisputesHelper
  def create
    @lesson = Lesson.find(params[:dispute][:lesson_id])
    @dispute = @lesson.disputes.create(dispute_params.merge(user_id: current_user.id))
    redirect_to disputes_path
  end

  def index
    @lessons = Lesson.all
    @lessons_disputes = @lessons.where("raise_a_dispute_sponsor IS NOT NULL OR raise_a_dispute_hunter IS NOT NULL ").where("refund_bounty_tx_id IS NULL")
  end

  def full_refund_bounty
    @lesson = Lesson.find(params[:lesson_id])
    @winning_bid = Rsvp.find(@lesson.awardee_id)
    @hunter = @winning_bid.attendee
    @sponsor = @lesson.organizer
    @refunded_to = User.find(params[:user_id])
    if @refunded_to == @sponsor
      @lesson.owner_cancel_auto_refund
    else
      @lesson.solver_auto_refund
    end
    redirect_to disputes_path
  end

  def partial_refund_bounty
    @lesson = Lesson.find(params[:lesson_id])
    @amount_sponsor = params[:amount_sponsor]
    @amount_hunter  = params[:amount_hunter]
    @sponsor = @lesson.organizer
    @winning_bid = Rsvp.find(@lesson.awardee_id)
    @hunter = @winning_bid.attendee
    @winning_bid_amount = @winning_bid.bid
    @lesson.partial_refund_bounty_actions(@amount_sponsor, @amount_hunter)
    redirect_to disputes_path
  end

  private
  def dispute_params
    params.require(:dispute).permit(:lesson_id, :body, :user_id, :amount_hunter, :amount_sponsor)
  end

  def authorize_admin
    redirect_to(root_path) unless current_user && current_user.admin?
  end
end
