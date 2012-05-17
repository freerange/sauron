require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  setup do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end

  test "loads conversations" do
    conversations = [conversation_stub('conversation-1'), conversation_stub('conversation-2')]
    ConversationRepository.stubs(:conversations).returns(conversations)
    get :index
    assert_equal conversations, assigns(:conversations)
  end

  test "#index displays a message if no recent conversations are found" do
    ConversationRepository.stubs(:conversations).returns([])
    get :index
    assert_select 'ul#conversations', count: 0
    assert_select 'p', text: 'No conversations were found'
  end
end
