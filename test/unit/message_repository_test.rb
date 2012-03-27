require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses MessageRepository::Record by default' do
    model = stub('model')
    assert_equal MessageRepository::Record, MessageRepository.new.model
  end

  test 'adds messages by creating a model' do
    model = stub('model')
    message = Mail.new(subject: 'Subject', from: 'tom@example.com', date: Date.today).to_s
    repository = MessageRepository.new(model)
    model.expects(:create!).with(account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today)
    repository.add('sam@example.com', 123, message)
  end

  test 'uses model to check if messages already exist' do
    model = stub('model')
    repository = MessageRepository.new(model)
    scope = stub('scope')
    model.stubs(:where).with(account: 'sam@example.com', uid: 1).returns(scope)
    scope.stubs(:exists?).returns(true)
    assert repository.exists?('sam@example.com', 1)
  end

  test 'retrieves all messages from the message store' do
    model = stub('model')
    repository = MessageRepository.new(model)
    message = stub('message')
    model.stubs(:all).returns([message])
    assert_equal [MessageRepository::Message.new(message)], repository.messages
  end
end