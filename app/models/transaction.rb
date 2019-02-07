class Transaction < ActiveRecord::Base
  belongs_to :wallet
  after_create :cash_out_request_email, if: -> {transaction_type == 2}

  def cash_out_request_email
    @user = self.wallet.user
    CashOutMailer.cash_out_request_email(@user, amount).deliver
  end

  def cash_out_success_email
    @user = self.wallet.user
    CashOutMailer.cash_out_success_email(@user, amount).deliver
  end

  def cash_out_success_push
    @amount = ActionController::Base.helpers.number_to_currency(amount)
    @user = self.wallet.user
    @endpoint = @user.endpoint
    @p256dh = @user.p256dh
    @auth = @user.auth
    @message = {
      title: "Your Cash Out request is succesful! Ka-ching!",
      body: "#{@amount} has been deposited into your account",
      data: {
        url: Rails.application.routes.url_helpers.wallet_path
      }
    }
    Webpush.payload_send(
      message: JSON.generate(@message),
      endpoint: @endpoint,
      p256dh: @p256dh,
      auth: @auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'mailto:sender@example.com',
        #public_key: ENV['VAPID_PUBLIC'],
        #private_key: ENV['VAPID_PRIVATE']
        public_key:'BDCyQd_y3d3kX15afKF7OF44te-Y3dCcVz0LIcPNlRpEHFYB58B2noKwzBsfRaf3ZvALRm998-lMv69IEXfOISQ',
        private_key: '1rC78sAgO8PZ66VJ7cfT1IiLehEXQ25RyTHyG3T-mk8',
        expiration: 24 * 60 * 60
      }
    )
  end

  def update_cash_out_id(tx_id)
    self.update_attribute(:cash_out_id, tx_id)
    self.cash_out_success_email
    self.cash_out_success_push
  end

  handle_asynchronously :cash_out_request_email, :run_at => Time.now
  handle_asynchronously :cash_out_success_email, :run_at => Time.now
  handle_asynchronously :cash_out_success_push, :run_at => Time.now
end
