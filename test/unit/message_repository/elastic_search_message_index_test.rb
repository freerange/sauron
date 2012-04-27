require "test_helper"

class MessageRepository
  class ElasticSearchMessageIndexTest < ActiveSupport::TestCase
    setup do
      ElasticSearchMessageIndex.destroy
    end

    test ".add ignores messages with the same message id" do
      message = stub('message', account: 'mark@example.com', uid: 94, message_id: 'abcd', subject: 'Hi', date: Time.now, from: 'tom@example.com')
      duplicate = stub('message', account: 'jerry@example.com', uid: 21, message_id: 'abcd', subject: 'Hi', date: Time.now, from: 'tom@example.com')
      ElasticSearchMessageIndex.add(message)
      ElasticSearchMessageIndex.add(duplicate)
      assert_equal 1, ElasticSearchMessageIndex.most_recent.size
    end

    test ".find reads a single message from the index" do
      message = stub('message', account: 'jerry@example.com', uid: 21, message_id: 'abcd', subject: 'Hi', date: Time.now, from: 'tom@example.com')
      key = ElasticSearchMessageIndex.add(message)
      found = ElasticSearchMessageIndex.find(key)

      assert_equal message.account, found.account
      assert_equal message.uid, found.uid
      assert_equal message.subject, found.subject
      assert_equal message.date.to_s, found.date.to_s
      assert_equal message.from, found.from
    end

    test ".messages returns 500 most recent messages" do
      501.times do |i|
        m = stub('message', account: 'jerry@example.com', uid: i, subject: 'Hi', date: Time.now + i.minutes, from: 'tom@example.com', message_id: i.to_s )
        ElasticSearchMessageIndex.add(m)
      end

      messages = ElasticSearchMessageIndex.most_recent
      assert_equal 500, messages.count
      assert_equal 500, messages.first.uid
      assert_equal 1, messages.last.uid
    end

    test ".message_exists? returns a truthy value if a message exists matching the account and uid" do
      message = stub('message', account: 'jerry@example.com', uid: 94, subject: 'Hi', date: Time.now, from: 'tom@example.com', message_id: '1234')
      ElasticSearchMessageIndex.add message
      assert ElasticSearchMessageIndex.message_exists?('jerry@example.com', 94)
    end

    test ".message_exists? returns a falsey value if messages only exist matching the account" do
      message = stub('message', account: 'jerry@example.com', uid: 94, subject: 'Hi', date: Time.now, from: 'tom@example.com', message_id: '1234')
      refute ElasticSearchMessageIndex.message_exists?('different@example.com', 94)
    end

    test ".message_exists? returns a falsey value if messages only exist matching the uid" do
      message = stub('message', account: 'jerry@example.com', uid: 94, subject: 'Hi', date: Time.now, from: 'tom@example.com', message_id: '1234')
      refute ElasticSearchMessageIndex.message_exists?('jerry@example.com', 123)
    end

    test ".highest_uid returns nil if there are no messages" do
      assert_nil ElasticSearchMessageIndex.highest_uid('jerry@example.com')
    end

    test ".highest_uid returns highest UID for the given account" do
      message = stub('message', account: 'jerry@example.com', uid: 94, subject: 'Hi', date: Time.now, from: 'tom@example.com', message_id: '1234')
      ElasticSearchMessageIndex.add message
      assert_equal 94, ElasticSearchMessageIndex.highest_uid('jerry@example.com')
    end
  end
end