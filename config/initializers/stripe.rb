Rails.configuration.stripe = {
  :publishable_key => ENV['S_E_API'],
  :secret_key      => ENV['S_E_API_R']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
