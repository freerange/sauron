require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:password")
  end

  test "#index assigns messages from Gmail" do
    messages = [Mail.new("FROM: George\nDate: 2012-01-01 12:00:00"), Mail.new("FROM: Bob\nDate: 2012-01-01 12:00:00")]
    MessageRepository.stubs(:messages).with().returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end
end