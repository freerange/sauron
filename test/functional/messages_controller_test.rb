require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    logged_in
  end

  test "#index indicates which messages were neither sent nor received by the current user" do
    neither_sent_nor_received = message_stub('message', subject: "neither-sent-nor-received", sent_or_received_by?: false)
    MessageRepository.stubs(:messages).with().returns([neither_sent_nor_received])
    get :index
    assert_select ".message.neither-sent-nor-received .subject", text: "neither-sent-nor-received"
  end

  test "#index indicates which messages were sent or received by the current user" do
    sent_or_received = message_stub('message', subject: "sent-or-received", sent_or_received_by?: true)
    MessageRepository.stubs(:messages).with().returns([sent_or_received])
    get :index
    assert_select ".message.sent-or-received .subject", text: "sent-or-received"
  end

  test "#index finds messages via repository" do
    messages = [message_stub('message-1'), message_stub('message-2')]
    MessageRepository.stubs(:messages).with().returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end

  test "#index displays a message if no recent messages are found" do
    MessageRepository.stubs(:messages).returns([])
    get :index
    assert_select 'ul#messages', count: 0
    assert_select 'p', text: 'No messages were found'
  end

  test "#show finds message via repository" do
    message = message_stub('message')
    MessageRepository.stubs(:find).with('1234').returns(message)
    get :show, id: '1234'
    assert_equal message, assigns[:message]
  end

  test "#show displays the body of the message" do
    message = message_stub('message', body: 'message-body')
    MessageRepository.stubs(:find).returns(message)
    get :show, id: '1'
    assert_select '.body', text: /message-body/
  end

  test "#show displays the 'to' recipients of the message" do
    message = message_stub('message', to: ['dave@example.com', 'john@example.com'])
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
    messages = [message_stub('message-1'), message_stub('message-2')]
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

  test "#search displays a message if no matching messages are found" do
    MessageRepository.stubs(:search).returns([])
    get :search, q: 'a-query-string'
    assert_select 'ul#messages', count: 0
    assert_select 'p', text: 'No messages were found'
  end
end