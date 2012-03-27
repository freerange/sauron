require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  stub(:model, create!: nil)
  stub(:store, add: nil)

  let(:repository) { MessageRepository.new(model, store) }

  test 'uses MessageRepository::Record by default' do
    assert_equal MessageRepository::Record, MessageRepository.new.model
  end

  test 'adds messages by creating a model' do
    message = Mail.new(subject: 'Subject', from: 'tom@example.com', date: Date.today).to_s
    model.expects(:create!).with(account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today)
    repository.add('sam@example.com', 123, message)
  end

  test 'adds original message data to message store' do
    message = Mail.new(subject: 'Subject', from: 'tom@example.com', date: Date.today).to_s
    store.expects(:add).with('sam@example.com', 123, message)
    repository.add('sam@example.com', 123, message)
  end

  test 'uses model to check if messages already exist' do
    scope = stub('scope')
    scope.stubs(:exists?).returns(true)
    model.stubs(:where).with(account: 'sam@example.com', uid: 1).returns(scope)
    assert repository.exists?('sam@example.com', 1)
  end

  test 'retrieves all messages from the model' do
    message = stub('message', account: 'tom@example.com', uid: 123)
    model.stubs(:all).returns([message])
    assert_equal [MessageRepository::Message.new(message)], repository.messages
  end

  test 'finds a single message from the model' do
    message = stub('message', account: 'tom@example.com', uid: 123)
    scope = stub('scope')
    model.stubs(:where).with(id: '123').returns(scope)
    scope.stubs(:first).returns(message)
    assert_equal MessageRepository::Message.new(message), repository.find('123')
  end
end