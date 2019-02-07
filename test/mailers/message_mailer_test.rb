require 'test_helper'

class MessageMailerTest < ActionMailer::TestCase
  test "new_message_email" do
    mail = MessageMailer.new_message_email
    assert_equal "New message email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
