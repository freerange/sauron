require "test_helper"

class ConversationRepository
  class ConversationTest < ActiveSupport::TestCase
    test "uses the identifier when involved in generating URLs" do
      identifier = "abc123"
      c = Conversation.new(conversation_record_stub('record', identifier: identifier))
      assert_equal identifier, c.to_param
    end
  end
end