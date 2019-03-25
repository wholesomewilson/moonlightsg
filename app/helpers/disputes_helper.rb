module DisputesHelper

  def full_refund_bounty_transactions(sponsor, hunter, refunded_to, transaction_type, amount, lesson)
    @transaction_refund = refunded_to.wallet.transactions.create(transaction_type: transaction_type, amount: amount, lesson_id: lesson) # 3 = refund to owner
    refunded_to.wallet.update_wallet_balance(@transaction_refund)
    sponsor.remove_from_ongoing_and_add_to_completed_problems_owner(lesson)
    hunter.remove_from_ongoing_and_add_to_completed_problems_solver(lesson)
  end

  def partial_refund_bounty_transactions(sponsor, hunter, amount_sponsor, amount_hunter, lesson)
    @transaction_sponsor = sponsor.wallet.transactions.create(transaction_type: 6, amount: amount_sponsor, lesson_id: lesson) # 3 = refund to owner
    sponsor.wallet.update_wallet_balance(@transaction_sponsor)
    @transaction_hunter = hunter.wallet.transactions.create(transaction_type: 6, amount: amount_hunter, lesson_id: lesson) # 4 = refund to solver
    hunter.wallet.update_wallet_balance(@transaction_hunter)
    sponsor.remove_from_ongoing_and_add_to_completed_problems_owner(lesson)
    hunter.remove_from_ongoing_and_add_to_completed_problems_solver(lesson)
  end
end
