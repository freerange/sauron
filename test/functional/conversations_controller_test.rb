require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  setup do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end

  def conversation_stub(stub_name, attributes = {})
    stub(stub_name, {
      latest_message_date: Time.now,
      subject: 'subject',
    }.merge(attributes))
  end

  test "loads conversations" do
    conversations = [conversation_stub('conversation-1'), conversation_stub('conversation-2')]
    ConversationRepository.stubs(:conversations).returns(conversations)
    get :index
    assert_equal conversations, assigns(:conversations)
  end
end
