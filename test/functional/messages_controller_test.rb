require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end

  test "#index indicates which messages were neither sent nor received by the current user" do
    neither_sent_nor_received = stub_everything("neither-sent-nor-received", subject: "neither-sent-nor-received", sent_or_received_by?: false)
    MessageRepository.stubs(:messages).with().returns([neither_sent_nor_received])
    get :index
    assert_select ".message.neither-sent-nor-received .subject", text: "neither-sent-nor-received"
  end

  test "#index indicates which messages were sent or received by the current user" do
    sent_or_received = stub_everything("sent-or-received", subject: "sent-or-received", sent_or_received_by?: true)
    MessageRepository.stubs(:messages).with().returns([sent_or_received])
    get :index
    assert_select ".message.sent-or-received .subject", text: "sent-or-received"
  end

  test "#index finds messages via repository" do
    messages = [stub_everything("message-1"), stub_everything("message-2")]
    MessageRepository.stubs(:messages).with().returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end

  test "#show finds message via repository" do
    message = stub_everything('message', recipients: [])
    MessageRepository.stubs(:find).with('1234').returns(message)
    get :show, id: '1234'
    assert_equal message, assigns[:message]
  end

  test "#show displays the body of the message" do
    message = stub_everything(body: 'message-body', recipients: [])
    MessageRepository.stubs(:find).returns(message)
    get :show, id: '1'
    assert_select '.body', text: /message-body/
  end
end