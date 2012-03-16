require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  test "#index assigns messages from Gmail" do
    messages = [Mail.new("FROM: George"), Mail.new("FROM: Bob")]
    GmailAccount.email = "email"
    GmailAccount.password = "password"
    GmailAccount.stubs(:messages).with("email", "password").returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end
end