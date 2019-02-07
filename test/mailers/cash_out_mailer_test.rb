require 'test_helper'

class CashOutMailerTest < ActionMailer::TestCase
  test "cash_out_request_email" do
    mail = CashOutMailer.cash_out_request_email
    assert_equal "Cash out request email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cash_out_success_email" do
    mail = CashOutMailer.cash_out_success_email
    assert_equal "Cash out success email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
