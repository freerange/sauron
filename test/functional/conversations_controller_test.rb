require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  setup do
    logged_in
  end

  def conversation(name, record_attributes={})
    ConversationRepository::Conversation.new(conversation_record_stub(name, record_attributes))
  end

  test "loads conversations" do
    conversations = [conversation('a'), conversation('b')]
    ConversationRepository.stubs(:conversations).returns(conversations)
    get :index
    assert_equal conversations, assigns(:conversations)
  end

  test "displays a message if no recent conversations are found" do
    ConversationRepository.stubs(:conversations).returns([])
    get :index
    assert_select 'ul#conversations', count: 0
    assert_select 'p', text: 'No conversations were found'
  end

  test "links to individual conversations" do
    conversations = [ConversationRepository::Conversation.new(conversation_record_stub('a'))]
    ConversationRepository.stubs(:conversations).returns(conversations)
    get :index
    assert_select 'ul#conversations' do
      assert_select 'a[href=?]', conversation_path(conversations[0])
    end
  end

  test "shows individual conversations" do
    conversation = conversation('a', subject: 'Hey there', id: 'abc123')
    ConversationRepository.stubs(:find).with('abc123').returns(conversation)
    get :show, id: 'abc123'
    assert_response :success
  end
end
