require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'stores messages in message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)

    message = stub('message')
    store.expects(:[]=).with(123, message)
    repository.store(123, message)
  end

  test 'indicates if a message exists in message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)
    store.stubs(:include?).with(1).returns(true)
    store.stubs(:include?).with(2).returns(false)
    assert repository.include?(1)
    refute repository.include?(2)
  end

  test 'retrieves all messages from the message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)
    store.stubs(:values).returns(["Subject: One", "Subject: Two"])
    assert_equal [Mail.new("Subject: One"), Mail.new("Subject: Two")], repository.messages
  end
end