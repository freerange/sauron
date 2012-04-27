require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:password")
  end

  test "#index finds messages via repository" do
    messages = [Mail.new("FROM: George\nDate: 2012-01-01 12:00:00"), Mail.new("FROM: Bob\nDate: 2012-01-01 12:00:00")]
    MessageRepository.stubs(:messages).with().returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end

  test "#show finds message via repository" do
    message = stub_everything('message', recipients: [], raw_messages: [])
    MessageRepository.stubs(:find).with('1234').returns(message)
    get :show, id: '1234'
    assert_equal message, assigns[:message]
  end

  test "#show displays the body of the message" do
    message = stub_everything(body: 'message-body', recipients: [], raw_messages: [])
    MessageRepository.stubs(:find).returns(message)
    get :show, id: '1'
    assert_select '.body', text: /message-body/
  end
end