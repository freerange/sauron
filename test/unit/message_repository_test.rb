require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses MessageRepository::Record by default' do
    model = stub('model')
    assert_equal MessageRepository::Record, MessageRepository.new.model
  end

  test 'adds messages by creating a model' do
    model = stub('model')
    raw_message = Mail.new(subject: 'Subject', from: 'tom@example.com', date: Date.today).to_s
    repository = MessageRepository.new(model)
    model.expects(:create!).with(account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today)
    repository.add('sam@example.com', 123, raw_message)
  end

  test 'adds original message data to message store' do
    model = stub('model', create!: nil)
    store = stub('store')
    raw_message = Mail.new(subject: 'Subject', from: 'tom@example.com', date: Date.today).to_s
    repository = MessageRepository.new(model, store)
    store.expects(:add).with('sam@example.com', 123, raw_message)
    repository.add('sam@example.com', 123, raw_message)
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