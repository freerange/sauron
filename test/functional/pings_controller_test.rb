require 'test_helper'

class PingsControllerTest < ActionController::TestCase
  setup do
    MessageRepository.stubs(:messages)
    ConversationRepository.stubs(:conversations)
  end

  test "#show does not requite authentication" do
    get :show
    assert_response :ok
  end

  test "#show accesses message repository" do
    MessageRepository.expects(:messages).with(1)
    get :show
  end

  test "#show accesses conversation repository" do
    ConversationRepository.expects(:conversations)
    get :show
  end
end
