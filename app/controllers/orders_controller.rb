class OrdersController < ApplicationController
  include OrdersHelper
  def index
    @closedate = DateTime.parse("#{'19-06-2019'} #{'00'}:#{'00'}#{'AM'}")
    @orderitems = current_user.orderitems.where(["status IS ? or status = ?", nil, '0']).sort_by {|x| x.created_at}
    @order = Order.new
    @orders_not_delivered = current_user.orders.where(["status = ? or status = ? or status = ?", '0', '1', '2']) if current_user.orders.present?
    @orders_delivered = current_user.orders.where(["status = ? or status = ?", '3', '4']) if current_user.orders.present?
    @total_bill_dec = @orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum
    @withoutswift_dec = @total_bill_dec
    @withoutswift = view_context.number_to_currency(@total_bill_dec)
    if @orderitems.present?
      @swifttimer = @orderitems.last.created_at + 15.minutes + 55.seconds
      if @swifttimer > DateTime.current
        @total_bill_dec = @total_bill_dec * 0.95
        @swiftdiscount = @withoutswift_dec * 0.05
      end
    else
      @swifttimer = DateTime.parse("#{'12-06-2001'} #{'00'}:#{'00'}#{'AM'}")
    end
    @total_bill = view_context.number_to_currency(@total_bill_dec)
    @location = current_user.orders.last.location if current_user.orders.present?
    @deliveryslot = current_user.orders.last.location if current_user.orders.present?
  end

  def checkout
    @orderitems = current_user.orderitems.where("status is NULL")
    @swifttimer = @orderitems.last.created_at + 15.minutes + 55.seconds
    @bill_in_decimal = @orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum
    if @swifttimer > DateTime.current
      @bill_in_decimal = @bill_in_decimal * 0.95
    end
    @bill = view_context.number_to_currency(@bill_in_decimal)
    @order = Order.new
    respond_to do |format|
      format.js { render 'payment_form_express.js.erb'}
    end
  end

  def update
    @order = Order.find(params[:id])
    if params[:delivery_date].present?
      @delivery_date = parse_time(params[:delivery_date], params[:delivery_hour], params[:delivery_minute], params[:delivery_ampm])
      @order.update_attribute(:deliver_datetime, @delivery_date)
      respond_to do |format|
        if @order.save
          flash[:success] = "Delivery Date is updated!"
          format.html {redirect_to orders_path}
        end
      end
    else
      @order.update(order_params)
      respond_to do |format|
        if @order.save
          format.html { redirect_to admin_path}
        end
      end
    end
  end

  def create
    @orderitems = current_user.orderitems.where("status is NULL")
    @swifttimer = @orderitems.last.created_at + 25.minutes
    @bill = @orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum
    if @swifttimer > DateTime.current
      @bill = @bill * 0.95
    end
    @wallet_balance = current_user.wallet.balance
    @order = current_user.orders.create(order_params)
    @location = @order.build_location(location_params)
	  @deliveryslot = @order.build_deliveryslot(deliveryslot_params)
    if params[:wallet_deduct] == 'true'
      @bill = @bill - @wallet_balance
      @transaction = current_user.wallet.transactions.create(transaction_type: 10, amount: @wallet_balance, lesson_id: @order.id)
      current_user.wallet.update_wallet_balance(@transaction)
    end
    if params[:payment_method] == '1' #PayNow
      current_user.orderitems.each {|orderitem| orderitem.update_attribute(:order_id, @order.id) if orderitem.status.blank?}
      current_user.orderitems.each {|orderitem| orderitem.update_attribute(:status, 1) if orderitem.order_id == @order.id }
      @order.update_attribute(:amount, @bill)
      @order.update_attribute(:payment_method, 1)
      @order.update_attribute(:status, 0)
      flash[:notice] = "Thank you for paying via PayNow!<br>We are verifying the payment now. :)"
    end
    if params[:payment_method] == '2' #Credit
      if @bill >= 10
        if params[:new_card] == 'true'
          create_customer_and_charge(current_user, params[:charge][:stripeToken], @bill, @order)
        else
          create_charge(current_user.wallet, @bill, @order)
        end
        current_user.orderitems.each {|orderitem| orderitem.update_attribute(:order_id, @order.id) if orderitem.status.blank?}
        current_user.orderitems.each {|orderitem| orderitem.update_attribute(:status, 1) if orderitem.order_id == @order.id }
        @order.update_attribute(:amount, @bill)
        @order.update_attribute(:payment_method, 2)
        @order.update_attribute(:status, 1)
        flash[:notice] = "Success! We are working on your orders!"
      else
        flash[:notice] = "Something went wrong! :( Please checkout your cart again."
      end
    end
    if params[:payment_method] == '3' #wallet (full)
      @transaction = current_user.wallet.transactions.create(transaction_type: 10, amount: @bill, lesson_id: @order.id)
      @order.update_attribute(:payment_transferred_id, @transaction.id)
      current_user.wallet.update_wallet_balance(@transaction)
      current_user.orderitems.each {|orderitem| orderitem.update_attribute(:order_id, @order.id) if orderitem.status.blank?}
      current_user.orderitems.each {|orderitem| orderitem.update_attribute(:status, 1) if orderitem.order_id == @order.id }
      @order.update_attribute(:amount, @bill)
      @order.update_attribute(:payment_method, 3)
      @order.update_attribute(:status, 1)
      flash[:notice] = "Success! We are working on your orders!"
    end
    redirect_to orders_path
  end

  def change_address
    @order = Order.find(params[:id])
    respond_to do |format|
      format.js { render 'delivery_address_post.js.erb'}
    end
  end

  def minimum_checkout
    @orderitems = current_user.orderitems.where(["status IS ? or status = ?", nil, '0']).sort_by {|x| x.created_at}
    @total_bill_dec = @orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum
    @total_bill = view_context.number_to_currency(@total_bill_dec)
    respond_to do |format|
      format.js { render 'minimum_checkout.js.erb'}
    end
  end

  private

  def deliveryslot_params
    params.require(:deliveryslot).permit(:date, :timeslot_id)
  end

  def location_params
    params.require(:location).permit(:block_no, :road_name, :building, :postal, :unit_no)
  end

  def order_params
    params.require(:order).permit(:payment_transferred_id, :payment_received_datetime, :status, :payment_method, :name, :contact_no)
  end
end
