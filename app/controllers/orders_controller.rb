class OrdersController < ApplicationController
  include OrdersHelper
  def index
    @orderitems = current_user.orderitems.where("status is NULL")
    @order = Order.new
    @orders_not_delivered = current_user.orders.where(["status = ? or status = ? or status = ?", '0', '1', '2']) if current_user.orders.present?
    @orders_delivered = current_user.orders.where(status: 3) if current_user.orders.present?
    @total_bill = view_context.number_to_currency(@orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum)
    @location = current_user.orders.last.location if current_user.orders.present?
  end

  def checkout
    @orderitems = current_user.orderitems.where("status is NULL")
    @bill_in_decimal = @orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum
    @bill = view_context.number_to_currency(@orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum)
    @order = Order.new
    respond_to do |format|
      format.js { render 'payment_form_express.js.erb'}
    end
  end

  def update
    @order = Order.find(params[:id])
    @order.update(order_params)
    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_path}
      end
    end
  end

  def create
    @delivery_date = parse_time(params[:payment_delivery_date], params[:payment_delivery_hour], params[:payment_delivery_minute], params[:payment_delivery_ampm])
    @orderitems = current_user.orderitems.where("status is NULL")
    @bill = @orderitems.map {|orderitem| (orderitem.quantity * orderitem.item.price_my) if orderitem.status.blank? }.sum
    @wallet_balance = current_user.wallet.balance
    @order = current_user.orders.create(order_params.merge(deliver_datetime: @delivery_date))
    @location = @order.build_location(location_params)
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


  private

  def location_params
    params.require(:location).permit(:block_no, :road_name, :building, :postal, :unit_no)
  end

  def order_params
    params.require(:order).permit(:payment_transferred_id, :payment_received_datetime, :status, :payment_method, :name, :contact_no)
  end
end
