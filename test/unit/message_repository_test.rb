require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses a FileBasedMessageStore by default' do
    store = stub('store')
    FileBasedMessageStore.stubs(:new).returns(store)
    assert_equal store, MessageRepository.new.message_store
  end

  test 'stores messages in message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)
    message = :message
    store.expects(:[]=).with(123, :message)
    repository.add(123, :message)
  end

  test 'indicates if a message exists in message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)
    store.stubs(:include?).with(1).returns(true)
    store.stubs(:include?).with(2).returns(false)
    assert repository.exists?(1)
    refute repository.exists?(2)
  end

  test 'retrieves all messages from the message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)
    store.stubs(:values).returns(["Subject: One", "Subject: Two"])
    assert_equal [Mail.new("Subject: One"), Mail.new("Subject: Two")], repository.messages
  end
end