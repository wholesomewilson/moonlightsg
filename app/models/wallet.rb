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

  def update_wallet_balance(transaction) #platform fees, update admin wallet
    if transaction.transaction_type == 0
      if balance.present?
        @new_balance = balance + transaction.amount
      else
        @new_balance = transaction.amount
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
    if transaction.transaction_type == 2 || transaction.transaction_type == 7 #cash out request & wallet payment
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
    self.update_attribute(:balance, @new_balance)
  end
end
