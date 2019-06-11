class Wallet < ActiveRecord::Base
  belongs_to :user
  has_many :transactions
  # 0 = fee
  # 1 = transfer bounty to solver
  # 2 = cash out request
  # 3 = cash out processed

  # 4 = refund to owner
  # 5 = refund to solver
  # 6 = partial refund

  # 7 = wallet payment
  # 8 = credit card payment
  # 9 = paynow payment

  # 10 = express order payment
  # 11 = credit card payment (express)
  # 12 = paynow payment (express)
  # 13 = boost credit

  def update_wallet_balance(transaction) #platform fees, update admin wallet
    if transaction.transaction_type == 0
      if self.user.admin
        if balance.present?
          @new_balance = balance + transaction.amount
        else
          @new_balance = transaction.amount
        end
      else
        if balance.present?
          @new_balance = balance - transaction.amount
        else
          @new_balance = transaction.amount
        end
      end
    end
    if transaction.transaction_type == 1 # transfer bounty to solver, refund to owner, refund to solver
      if balance.present?
        @new_balance = balance + transaction.amount
        Lesson.find(transaction.lesson_id).update_attribute(:bounty_transferred_id, transaction.id)
      else
        @new_balance = transaction.amount
      end
    end
    if transaction.transaction_type == 2 || transaction.transaction_type == 7 || transaction.transaction_type == 10 #cash out request & wallet payment
      if balance.present?
        @new_balance = balance - transaction.amount
      else
        @new_balance = transaction.amount
      end
    end
    if transaction.transaction_type == 4 || transaction.transaction_type == 5 || transaction.transaction_type == 6  # transfer bounty to solver, refund to owner, refund to solver
      if balance.present?
        @new_balance = balance + transaction.amount
        Lesson.find(transaction.lesson_id).update_attribute(:refund_bounty_tx_id, transaction.id)
      else
        @new_balance = transaction.amount
      end
    end
    if transaction.transaction_type == 13  # credit boost to user's wallet
      if balance.present?
        @new_balance = balance + transaction.amount
      else
        @new_balance = transaction.amount
      end
    end
    self.update_attribute(:balance, @new_balance)
  end

  def update_c_d(current_user)
    @customer_id = current_user.wallet.customer_id
    @stripe_customer = Stripe::Customer.retrieve(@customer_id)
    @default_card_id = @stripe_customer.default_source
    @default_card = @stripe_customer.sources[:data].find {|x| x[:id] == @default_card_id }
    self.update_attribute(:last4, @default_card.last4)
    self.update_attribute(:brand, @default_card.brand)
  end

  handle_asynchronously :update_c_d, :run_at => Time.now
end
