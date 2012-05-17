require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end

  def message_stub(attributes = {})
    stub_everything('message', {
      recipients: [],
      to: []
    }.merge(attributes))
  end

  test "#index indicates which messages were neither sent nor received by the current user" do
    neither_sent_nor_received = message_stub(subject: "neither-sent-nor-received", sent_or_received_by?: false)
    MessageRepository.stubs(:messages).with().returns([neither_sent_nor_received])
    get :index
    assert_select ".message.neither-sent-nor-received .subject", text: "neither-sent-nor-received"
  end

  test "#index indicates which messages were sent or received by the current user" do
    sent_or_received = message_stub(subject: "sent-or-received", sent_or_received_by?: true)
    MessageRepository.stubs(:messages).with().returns([sent_or_received])
    get :index
    assert_select ".message.sent-or-received .subject", text: "sent-or-received"
  end

  test "#index finds messages via repository" do
    messages = [message_stub, message_stub]
    MessageRepository.stubs(:messages).with().returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end

  test "#show finds message via repository" do
    message = message_stub
    MessageRepository.stubs(:find).with('1234').returns(message)
    get :show, id: '1234'
    assert_equal message, assigns[:message]
  end

  test "#show displays the body of the message" do
    message = message_stub(body: 'message-body')
    MessageRepository.stubs(:find).returns(message)
    get :show, id: '1'
    assert_select '.body', text: /message-body/
  end

  test "#show displays the 'to' recipients of the message" do
    message = message_stub(to: ['dave@example.com', 'john@example.com'])
    MessageRepository.stubs(:find).returns(message)
    get :show, id: '1'
    assert_select '.to', text: /dave@example.com/
    assert_select '.to', text: /john@example.com/
  end

  test "#show responds with 404 for non-existent messages" do
    MessageRepository.stubs(:find).returns(nil)
    get :show, id: 'non-existent-message'
    assert_response :not_found
  end

  test "#search finds messages via repository" do
    messages = [message_stub, message_stub]
    MessageRepository.stubs(:search).with('search-term').returns(messages)
    get :search, q: 'search-term'
    assert_equal messages, assigns[:messages]
  end

  test "#search with empty query does not query repository" do
    MessageRepository.expects(:search).never
    get :search, q: ''
  end

  test "#search with empty query redirects to messages page" do
    get :search, q: ''
    assert_redirected_to action: 'index'
  end

  test "#search displays previous query in search input" do
    MessageRepository.stubs(:search).returns([])
    get :search, q: 'a-query-string'
    assert_select '#q[value=a-query-string]'
  end
end