class ChargesController < ApplicationController
  include ChargesHelper
  def new
  end

  def create
    @lesson = Lesson.find(params[:lesson_id])
    @bounty = Rsvp.find(params[:awardee_id]).bid
    @wallet_balance = current_user.wallet.balance
    if @lesson.bounty_type == 2
      @bounty = @bounty + @lesson.deposit
    end
    if params[:wallet_deduct] == 'true'
      @bounty = @bounty - @wallet_balance
      @transaction = current_user.wallet.transactions.create(transaction_type: 7, amount: current_user.wallet.balance, lesson_id: @lesson.id)
      current_user.wallet.update_wallet_balance(@transaction)
    end
    if params[:bounty_received_method] == '1' #PayNow
      @lesson.update_attribute(:bounty_received_method, 1)
      @lesson.update_attribute(:pending_awardee_id, params[:awardee_id].to_i)
    end
    if params[:bounty_received_method] == '2' #Credit
      if @bounty >= 10
        if params[:new_card] == 'true'
          create_customer_and_charge(current_user, params[:charge][:stripeToken], @bounty, @lesson, params[:awardee_id].to_i)
        else
          create_charge(current_user.wallet, @bounty, @lesson, params[:awardee_id].to_i)
        end
      else
        flash[:notice] = "Something went wrong! :( Please award your job again."
      end
    end
    if params[:bounty_received_method] == '3' #wallet (full)
      @lesson.update_attribute(:bounty_received_method, 3)
      @lesson.update_attribute(:bounty_received_datetime, DateTime.current)
      @lesson.update_attribute(:awardee_id, params[:awardee_id].to_i)
      @transaction = current_user.wallet.transactions.create(transaction_type: 7, amount: @bounty, lesson_id: @lesson.id)
      @lesson.update_attribute(:bounty_transferred_id, @transaction.id)
      current_user.wallet.update_wallet_balance(@transaction)
    end
    redirect_to :back
  end

  def award
    @awardee_id = params[:awardee_id]
    @lesson_id =  params[:lesson_id]
    @lesson = Lesson.find(@lesson_id)
    @bid = Rsvp.find(@awardee_id).bid
    if @lesson.bounty_type == 2
      @bounty_in_decimal = @bid + @lesson.deposit
      @bounty = view_context.number_to_currency(@bid + @lesson.deposit)
    else
      @bounty_in_decimal = @bid
      @bounty = view_context.number_to_currency(@bid)
    end
    respond_to do |format|
      format.js { render 'payment_form.js.erb'}
    end
  end

  private

  def charge_params
    params.require(:charge).permit(:stripeToken, :lesson_id, :awardee_id, :bounty_received_method, :wallet_deduct, :new_card)
  end

end
