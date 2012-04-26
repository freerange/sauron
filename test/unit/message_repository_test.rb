require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses MessageRepository::ActiveRecordMessageIndex as default index' do
    model = stub('model')
    assert_equal MessageRepository::ActiveRecordMessageIndex, MessageRepository.new.index
  end

  test 'uses MessageRepository::CacheBackedMessageStore as default store' do
    model = stub('model')
    assert_equal CacheBackedMessageStore, MessageRepository.new.store
  end

  test 'adds message to record index' do
    model = stub('model')
    store = stub('store', add: nil)
    message = stub('message', account: 'sam@example.com', uid: 123, raw: 'raw-message')
    repository = MessageRepository.new(model, store)
    model.expects(:add).with(message)
    repository.add(message)
  end

  test 'adds message to message store' do
    model = stub('model', add: nil)
    store = stub('store')
    message = stub('message', account: 'sam@example.com', uid: 123, raw: 'raw-message')
    repository = MessageRepository.new(model, store)
    store.expects(:add).with(message)
    repository.add(message)
  end

  test 'uses model to obtain highest uid for account' do
    model = stub('model')
    model.stubs(:highest_uid).with('sam@example.com').returns(999)
    repository = MessageRepository.new(model)
    assert_equal 999, repository.highest_uid('sam@example.com')
  end

  test 'uses model to check if messages already exist' do
    model = stub('model')
    model.stubs(:message_exists?).with('sam@example.com', 1).returns(true)
    repository = MessageRepository.new(model)
    assert repository.exists?('sam@example.com', 1)
  end

  test 'retrieves the most recent messages from the model' do
    model = stub('model')
    repository = MessageRepository.new(model)
    message_record = stub('message_record', account: 'tom@example.com', uid: 123)
    model.stubs(:most_recent).returns([message_record])
    assert_equal [MessageRepository::Message.new(message_record)], repository.messages
  end

  test 'finds a single message from the model' do
    model = stub('model')
    scope = stub('scope')
    repository = MessageRepository.new(model)
    message_record = stub('message_record', account: 'tom@example.com', uid: 123)
    model.stubs(:where).with(id: '123').returns(scope)
    scope.stubs(:first).returns(message_record)
    assert_equal MessageRepository::Message.new(message_record), repository.find('123')
  end
end