require "test_helper"

class MessageThreadTest < Test::Unit::TestCase
  def test_creating_without_messages_doesnt_set_most_recent_message_timestamp
    thread = MessageThread.create!
    assert_nil thread.most_recent_message_at
  end

  def test_adding_message_updates_most_recent_message_timestamp
    thread = MessageThread.create!
    message = Message.create!(date: "2011-12-01 12:23:54 UTC")
    thread.messages << message
    thread.save
    assert_equal Time.parse("2011-12-01 12:23:54 UTC"), thread.most_recent_message_at
  end
end
