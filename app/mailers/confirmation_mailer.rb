class ConfirmationMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  add_template_helper(EmailHelper)
  def confirmation_instructions(record, token, opts={})
    opts[:from] = 'Moonlight <notifications@moonlight.sg>'
    opts[:reply_to] = 'Moonlight <notifications@moonlight.sg>'
    super
  end
end
