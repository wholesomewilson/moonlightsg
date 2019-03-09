class Wallet < ActiveRecord::Base
  belongs_to :user
  has_many :transactions

  def update_wallet_balance(transaction)
    if transaction.transaction_type == 1
      if balance.present?
        @new_balance = balance + transaction.amount
        Lesson.find(transaction.lesson_id).update_attribute(:bounty_transferred_id, transaction.id)
      else
        @new_balance = transaction.amount
      end
    end
    if transaction.transaction_type == 2
      if balance.present?
        @new_balance = balance - transaction.amount
        Lesson.find(transaction.lesson_id).update_attribute(:bounty_transferred_id, transaction.id)
      else
        @new_balance = transaction.amount
      end
    end
    if transaction.transaction_type == 3
      if balance.present?
        @new_balance = balance + transaction.amount
        Lesson.find(transaction.lesson_id).update_attribute(:bounty_transferred_id, transaction.id)
      else
        @new_balance = transaction.amount
      end
    end
    if transaction.transaction_type == 4
      if balance.present?
        @new_balance = balance + transaction.amount
        Lesson.find(transaction.lesson_id).update_attribute(:bounty_transferred_id, transaction.id)
      else
        @new_balance = transaction.amount
      end
    end
    self.update_attribute(:balance, @new_balance)
  end
end
