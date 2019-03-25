module ChargesHelper
  def create_customer_and_charge(current_user, stripeToken, bounty, lesson, awardee_id)
    @email = current_user.email
    @wallet = current_user.wallet
    customer = Stripe::Customer.create({
      email: @email,
      source: stripeToken,
    })
    charge = Stripe::Charge.create({
      customer: customer.id,
      amount: (100 * bounty.to_r).to_i,
      description: 'Moonlight',
      currency: 'sgd',
    })
    if customer.id
      @wallet.update_attribute(:customer_id, customer.id)
    end
    if charge.id
      @wallet.transactions.create(transaction_type: 8, amount: bounty, lesson_id: lesson.id)
      lesson.update_attribute(:bounty_received_datetime, DateTime.current)
      lesson.update_attribute(:bounty_transferred_id, charge.id)
      lesson.update_attribute(:awardee_id, awardee_id)
    end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
  end

  def create_charge(wallet, bounty, lesson, awardee_id)
    @customer_id = wallet.customer_id
    charge = Stripe::Charge.create({
      customer: @customer_id,
      amount: (100 * bounty.to_r).to_i,
      description: 'Moonlight',
      currency: 'sgd',
    })
    if charge.id
      wallet.transactions.create(transaction_type: 8, amount: bounty, lesson_id: lesson.id)
      lesson.update_attribute(:bounty_received_datetime, DateTime.current)
      lesson.update_attribute(:bounty_transferred_id, charge.id)
      lesson.update_attribute(:awardee_id, awardee_id)
    end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
  end
end
