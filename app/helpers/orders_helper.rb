module OrdersHelper
  def parse_time(date, hour, minute, ampm)
    @parsed_time = DateTime.parse("#{date} #{hour}:#{minute}#{ampm}")
  end

  def create_customer_and_charge(current_user, stripeToken, bill, order)
    @email = current_user.email
    @wallet = current_user.wallet
    customer = Stripe::Customer.create({
      email: @email,
      source: stripeToken,
    })
    charge = Stripe::Charge.create({
      customer: customer.id,
      amount: (100 * bill.to_r).to_i,
      description: 'Moonlight',
      currency: 'sgd',
    })
    if customer.id
      @wallet.update_attribute(:customer_id, customer.id)
      @wallet.update_c_d(current_user)
    end
    if charge.id
      order.update_attribute(:payment_received_datetime, DateTime.current)
      order.update_attribute(:payment_transferred_id, charge.id)
    end
    rescue Stripe::CardError => e
      flash[:notice] = e.message
  end

  def create_charge(wallet, bill, order)
    @customer_id = wallet.customer_id
    charge = Stripe::Charge.create({
      customer: @customer_id,
      amount: (100 * bill.to_r).to_i,
      description: 'Moonlight',
      currency: 'sgd',
    })
    if charge.id
      order.update_attribute(:payment_received_datetime, DateTime.current)
      order.update_attribute(:payment_transferred_id, charge.id)
    end
    rescue Stripe::CardError => e
      flash[:notice] = e.message
  end
end
