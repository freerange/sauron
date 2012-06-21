require "test_helper"

class ConversationRepository::ConversationTest < ActiveSupport::TestCase
  test "uses the identifier when involved in generating URLs" do
    identifier = "abc123"
    conversation = ConversationRepository::Conversation.new(conversation_record_stub('record', identifier: identifier))
    assert_equal identifier, conversation.to_param
  end

  test "returns messages ordered by most recent first" do
    newest_message = message_stub('newest message', message_id: '1', date: 1.minute.ago)
    oldest_message = message_stub('oldest message', message_id: '2', date: 10.days.ago)
    oldish_message = message_stub('oldish message', message_id: '3', date: 3.days.ago)
    messages = [newest_message, oldest_message, oldish_message]
    message_repository = stub('message repository')
    message_repository.stubs(:find_by_message_id).returns(*messages)

    record = conversation_record_stub('record', message_ids: ['1', '2', '3'])

    conversation = ConversationRepository::Conversation.new(record, message_repository)

    assert_equal [newest_message, oldish_message, oldest_message], conversation.messages
  end
end
