require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  setup do
    team = Team.new
    team.stubs(:has_member?).returns(false)
    team.stubs(:has_member?).with('james@example.com').returns(true)
    team.stubs(:has_member?).with('tom@example.com').returns(true)
    Team.stubs(:new).returns(team)
  end

  test "loads messages referenced in 'In-Reply-To' headers" do
    message = stub('message', message_id: 'message-id', date: 1.day.ago, in_reply_to: 'message-id-abc@123.example.com')
    repository.expects(:find_by_message_id).with('message-id-abc@123.example.com')
    conversation = Conversation.new(message, repository)
  end

  test "#messages returns messages ordered most recent first" do
    original_message = stub_message('original message', subject: 'Thing', date: 3.days.ago, message_id: 'message-id-1@example.com', from: 'james@example.com', in_reply_to: nil)
    their_reply = stub_message('their message', subject: 'Re: Thing', date: 2.days.ago, message_id: 'message-id-a@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    our_reply = stub_message('our reply message', subject: 'Re: Thing', date: 1.day.ago, message_id: 'message-id-2@example.com', from: 'tom@example.com', in_reply_to: 'message-id-a@otherserver.example.com')
    conversation = Conversation.new(our_reply, repository)
    assert_equal [our_reply, their_reply, original_message], conversation.messages
  end

  test "#messages includes all messages in a conversation" do
    original_message = stub_message('original message', subject: 'Thing', date: 4.days.ago, message_id: 'message-id-1@example.com', from: 'james@example.com', in_reply_to: nil)
    their_reply = stub_message('their reply', subject: 'Re: Thing', date: 3.days.ago, message_id: 'message-id-a@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    their_follow_up = stub_message('their follow up', subject: 'Re: Thing', date: 2.days.ago, message_id: 'message-id-b@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    our_reply = stub_message('our reply', subject: 'Re: Thing', date: 1.day.ago, message_id: 'message-id-2@example.com', from: 'tom@example.com', in_reply_to: 'message-id-a@otherserver.example.com')
    conversation = Conversation.new(our_reply, repository)
    assert_equal [our_reply, their_follow_up, their_reply, original_message], conversation.messages
  end

  test "#has_reply_from_us? returns false if the most recent message was not from our team" do
    original_message = stub_message('original message', subject: 'Thing', date: 3.days.ago, message_id: 'message-id-1@example.com', from: 'james@example.com', in_reply_to: nil)
    their_reply = stub_message('their message', subject: 'Re: Thing', date: 2.days.ago, message_id: 'message-id-a@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    conversation = Conversation.new(their_reply, repository)
    refute conversation.has_reply_from_us?
  end

  test "#has_reply_from_us? returns true if the most recent message was from our team" do
    original_message = stub_message('original message', subject: 'Thing', date: 3.days.ago, message_id: 'message-id-1@example.com', from: 'james@example.com', in_reply_to: nil)
    their_reply = stub_message('their message', subject: 'Re: Thing', date: 2.days.ago, message_id: 'message-id-a@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    our_reply = stub_message('our reply message', subject: 'Re: Thing', date: 1.day.ago, message_id: 'message-id-2@example.com', from: 'tom@example.com', in_reply_to: 'message-id-a@otherserver.example.com')
    conversation = Conversation.new(our_reply, repository)
    assert conversation.has_reply_from_us?
  end

  test "#has_reply_from_us? returns false if they send two replies but their most recent message has not received a reply" do
    original_message = stub_message('original message', subject: 'Thing', date: 4.days.ago, message_id: 'message-id-1@example.com', from: 'james@example.com', in_reply_to: nil)
    their_reply = stub_message('their message', subject: 'Re: Thing', date: 3.days.ago, message_id: 'message-id-a@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    their_follow_up = stub_message('their second message', subject: 'Re: Thing', date: 2.days.ago, message_id: 'message-id-b@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    our_reply = stub_message('our reply message', subject: 'Re: Thing', date: 1.day.ago, message_id: 'message-id-2@example.com', from: 'tom@example.com', in_reply_to: 'message-id-a@otherserver.example.com')
    conversation = Conversation.new(our_reply, repository)
    refute conversation.has_reply_from_us?
  end

  test "#has_reply_from_us? returns true if they send two replies and their most recent message has received a reply" do
    original_message = stub_message('original message', subject: 'Thing', date: 4.days.ago, message_id: 'message-id-1@example.com', from: 'james@example.com', in_reply_to: nil)
    their_reply = stub_message('their message', subject: 'Re: Thing', date: 3.days.ago, message_id: 'message-id-a@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    their_follow_up = stub_message('their second message', subject: 'Re: Thing', date: 2.days.ago, message_id: 'message-id-b@otherserver.example.com', from: 'them@otherserver.example.com', in_reply_to: 'message-id-1@example.com')
    our_reply = stub_message('our reply message', subject: 'Re: Thing', date: 1.day.ago, message_id: 'message-id-2@example.com', from: 'tom@example.com', in_reply_to: 'message-id-b@otherserver.example.com')
    conversation = Conversation.new(our_reply, repository)
    assert conversation.has_reply_from_us?
  end

  private

  def repository
    return @repository if @repository
    @repository = stub('message_repository')
    @repository.stubs(:find_by_message_id).returns(nil)
    @repository.stubs(:find_replies_to).returns([])
    @repository
  end

  def stub_message(name, attributes)
    message = stub(name, attributes)
    repository.stubs(:find_by_message_id).with(message.message_id).returns(message)
    replies = repository.find_replies_to(message.in_reply_to).dup
    replies << message
    repository.stubs(:find_replies_to).with(message.in_reply_to).returns(replies)
    message
  end
end