require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end

  test "#index indicates which messages were and were not received by the current user" do
    received = stub_everything("received", subject: "received", received_by?: true)
    not_received = stub_everything("not-received", subject: "not-received", received_by?: false)
    MessageRepository.stubs(:messages).with().returns([received, not_received])
    get :index
    assert_select ".message.received .subject", text: "received"
    assert_select ".message.not-received .subject", text: "not-received"
  end

  test "#index finds messages via repository" do
    messages = [stub_everything("message-1"), stub_everything("message-2")]
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