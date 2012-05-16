require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  setup do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end

  test "loads conversations" do
    conversations = [stub('conversation-1', subject: 'subject-1'), stub('conversation-2', subject: 'subject-1')]
    ConversationRepository.stubs(:conversations).returns(conversations)
    get :index
    assert_equal conversations, assigns(:conversations)
  end
end
