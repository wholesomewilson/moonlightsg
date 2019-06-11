module AdminHelper

  def boost_users(orders)
    orders.each do |x|
      @amount = (x.amount * 0.05).to_s.first(4).to_d
      @user = x.user
      @transaction = @user.wallet.transactions.create(transaction_type: 13, amount: @amount, lesson_id: @user.id)
      @user.wallet.update_wallet_balance(@transaction)
    end
  end

end
