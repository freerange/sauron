require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  test "#index assigns messages from Gmail" do
    messages = [Mail.new("FROM: George\nDate: 2012-01-01 12:00:00"), Mail.new("FROM: Bob\nDate: 2012-01-01 12:00:00")]
    GmailAccount.email = "email"
    GmailAccount.password = "password"
    GmailAccount.stubs(:messages).with("email", "password").returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end
end