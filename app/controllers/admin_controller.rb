class AdminController < ApplicationController
  before_filter :authorize_admin
  def index
    @lessons = Lesson.all
    @ongoing_lessons = Lesson.where("awardee_id IS NULL")
    @ongoing_lessons_paid_thru_paynow = Lesson.where("awardee_id IS NULL").where(bounty_received_method: 1)
    @ongoing_lessons_awarded_but_not_received = Lesson.where("awardee_id IS NOT NULL").where("bounty_received_datetime IS NULL")
    @ongoing_lessons_awarded = Lesson.where("awardee_id IS NOT NULL").where("job_completed_datetime IS NULL")
    @ongoing_lessons_completed = Lesson.where("job_completed_datetime IS NOT NULL").where("job_verified_datetime IS NULL")
    @ongoing_lessons_verified = Lesson.where("job_verified_datetime IS NOT NULL")
    @ongoing_lessons_verified_but_not_transferred = Lesson.where("job_verified_datetime IS NOT NULL").where("bounty_transferred_id IS NULL")
    @cash_out_requests = Transaction.where(transaction_type: 2).where("cash_out_id IS NULL")
    @express_paynow_not_sent = Orderitem.where(status: nil).where(reminder: nil)
    @express_paynow_not_checked_out = Orderitem.where(status: nil).sort_by { |x| x.created_at}
    @express_paynow_not_verified = Order.where(status: 0) if Order.all.present?
    @express_paynow_not_purchased = Order.where(status: 1) if Order.all.present?
    @express_paynow_not_delivered = Order.where(status: 2) if Order.all.present?
    @transaction = Transaction.new
    @users = User.all.sort_by { |x| x.created_at }
    @testimonials = Testimonial.all.sort_by { |t| t.created_at}
    @item = Item.first
  end

  def cash_out
    @wallet = Wallet.find(params[:id])
    @transaction = @wallet.transactions.build(transaction_params.merge(transaction_type: 3))
    if @transaction.save
      Transaction.find(params[:transaction][:cash_out_id]).update_cash_out_id(@transaction.id)
    end
    redirect_to admin_path
  end

  def bounty_received_paynow
    @wallet = User.first.wallet
    @lesson = Lesson.find(params[:transaction][:lesson_id])
    @transaction = @wallet.transactions.build(transaction_params.merge(transaction_type: 9))
    if @transaction.save
      @lesson.update_attribute(:bounty_received_datetime, DateTime.current)
      @lesson.update_attribute(:awardee_id, @lesson.pending_awardee_id)
      @lesson.update_attribute(:bounty_transferred_id, @transaction.id)
      @lesson.pay_now_verified
    end
    redirect_to admin_path
  end

  private

  def transaction_params
    params.require(:transaction).permit(:amount, :cash_out_id, :bank_tx_id, :lesson_id)
  end
end
