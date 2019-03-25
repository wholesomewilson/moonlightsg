class DisputesController < ApplicationController
  before_filter :authorize_admin, only: [:index]
  include DisputesHelper
  def create
    @lesson = Lesson.find(params[:dispute][:lesson_id])
    @dispute = @lesson.disputes.create(dispute_params.merge(user_id: current_user.id))
    redirect_to :back
  end

  def index
    @lessons = Lesson.all
    @lessons_disputes = @lessons.where("raise_a_dispute_sponsor IS NOT NULL OR raise_a_dispute_hunter IS NOT NULL ").where("refund_bounty_tx_id IS NULL")
  end

  def full_refund_bounty
    @lesson = Lesson.find(params[:lesson_id])
    @winning_bid = Rsvp.find(@lesson.awardee_id)
    @amount = @winning_bid.bid
    @hunter = @winning_bid.attendee
    @sponsor = @lesson.organizer
    @refunded_to = User.find(params[:user_id])
    if @refunded_to == @sponsor
      @transaction_type = 4
    else
      @transaction_type = 5
    end
    full_refund_bounty_transactions(@sponsor, @hunter, @refunded_to, @transaction_type, @amount, @lesson.id)
    redirect_to disputes_path
  end

  def partial_refund_bounty
    @lesson = Lesson.find(params[:lesson_id])
    @amount_sponsor = params[:amount_sponsor]
    @amount_hunter  = params[:amount_hunter]
    @sponsor = @lesson.organizer
    @hunter = Rsvp.find(@lesson.awardee_id).attendee
    partial_refund_bounty_transactions(@sponsor, @hunter, @amount_sponsor, @amount_hunter, @lesson.id)
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
