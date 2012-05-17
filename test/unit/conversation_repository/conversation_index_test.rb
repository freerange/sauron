require 'test_helper'

class ConversationRepository::ConversationIndexTest < ActiveSupport::TestCase
  setup do
    storage = ConversationRepository::ConversationIndex::ActiveRecordStore.new
    @index = ConversationRepository::ConversationIndex.new(storage)
  end

  test "two unrelated messages are in two conversations" do
    message = message_stub('message', message_id: 'message-id', subject: 'subject')
    another_message = message_stub('another-message', message_id: 'another-id', subject: 'another-subject')

    @index.add(message)
    @index.add(another_message)

    conversations = @index.most_recent

    assert_same_elements ['subject', 'another-subject'], conversations.map(&:subject)
  end

  test "a message and its replies are in a single conversation" do
    original_message = message_stub('original-message')
    reply_message_1 = reply_to(original_message, 'reply-message-1')
    reply_message_2 = reply_to(reply_message_1, 'reply-message-2')

    @index.add(original_message)
    @index.add(reply_message_1)
    @index.add(reply_message_2)

    conversations = @index.most_recent

    assert_equal 1, conversations.length
  end

  test "a message and the replies to its replies are in a single conversation" do
    original_message = message_stub('original-message')
    reply_message_1 = reply_to(original_message, 'reply-message-1')
    reply_message_2 = reply_to(reply_message_1, 'reply-message-2')

    @index.add(original_message)
    @index.add(reply_message_1)
    @index.add(reply_message_2)

    conversations = @index.most_recent

    assert_equal 1, conversations.length
  end

  test "all reply branches are in a single conversation" do
    original_message = message_stub('original-message')
    reply_message_1 = reply_to(original_message, 'reply-message-1')
    reply_message_2 = reply_to(reply_message_1, 'reply-message-2')
    reply_message_3 = reply_to(original_message, 'reply-message-3')

    @index.add(original_message)
    @index.add(reply_message_1)
    @index.add(reply_message_2)
    @index.add(reply_message_3)

    conversations = @index.most_recent

    assert_equal 1, conversations.length
  end

  test "messages should be added to the right conversation even if the reply is imported first" do
    original_message = message_stub('original-message')
    reply_message = reply_to(original_message, 'reply-message')

    unpredictable_order_of_server_messages = [reply_message, original_message]
    unpredictable_order_of_server_messages.each do |message|
      @index.add(message)
    end

    conversations = @index.most_recent

    assert_equal 1, conversations.length
  end

  test "the set of conversations should be the same regardless of the order messages are imported" do
    original_message = message_stub('original-message')
    reply_message = reply_to(original_message, 'reply-message')
    reply_branch_a_message_1 = reply_to(reply_message, 'reply-message-a-1')
    reply_branch_a_message_2 = reply_to(reply_branch_a_message_1, 'reply-message-a-2')
    reply_branch_a_message_3 = reply_to(reply_branch_a_message_2, 'reply-message-a-3')
    reply_branch_b_message_1 = reply_to(reply_message, 'reply-message-b-1')
    reply_branch_b_message_2 = reply_to(reply_branch_b_message_1, 'reply-message-b-2')

    unpredictable_order_of_server_messages = [
      original_message,
      reply_branch_a_message_1, reply_branch_a_message_2,
      reply_branch_b_message_1, reply_branch_b_message_2,
      reply_message,
      reply_branch_a_message_3
    ]
    unpredictable_order_of_server_messages.each do |message|
      @index.add(message)
    end

    conversations = @index.most_recent

    assert_equal 1, conversations.length
  end

  test "adding messages multiple times shouldn't produce duplicate conversations" do
    message = message_stub('message')

    3.times { @index.add(message) }

    conversations = @index.most_recent

    assert_equal 1, conversations.length
  end

  test "subject of a conversation is the subject of the latest emessage in the conversation" do
    original_message = message_stub('original-message', subject: 'original-subject', date: 3.days.ago)
    reply_message_1 = reply_to(original_message, 'reply-message-1', subject: 'reply-1-subject', date: 2.days.ago)
    reply_message_2 = reply_to(original_message, 'reply-message-2', subject: 'reply-2-subject', date: 1.day.ago)

    unpredictable_order_of_server_messages = [original_message, reply_message_2, reply_message_1]
    unpredictable_order_of_server_messages.each do |message|
      @index.add(message)
    end

    conversations = @index.most_recent

    assert_same_elements ['reply-2-subject'], conversations.map(&:subject)
  end
end
