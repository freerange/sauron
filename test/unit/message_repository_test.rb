require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses MailRepository::ActiveRecordMailIndex as default index' do
    model = stub('model')
    assert_equal MailRepository::ActiveRecordMailIndex, MessageRepository.new.mail_index
  end

  test 'uses MailRepository::CacheBackedMailStore as default store' do
    model = stub('model')
    assert_equal CacheBackedMailStore, MessageRepository.new.mail_store
  end

  test 'adds mail to record index' do
    model = stub('model')
    store = stub('store', add: nil)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message')
    repository = MessageRepository.new(model, store)
    model.expects(:add).with(mail)
    repository.add_mail(mail)
  end

  test 'adds mail to message store' do
    model = stub('model', add: nil)
    store = stub('store')
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message')
    repository = MessageRepository.new(model, store)
    store.expects(:add).with(mail)
    repository.add_mail(mail)
  end

  test 'uses model to obtain highest mail uid for account' do
    model = stub('model')
    model.stubs(:highest_uid).with('sam@example.com').returns(999)
    repository = MessageRepository.new(model)
    assert_equal 999, repository.highest_mail_uid('sam@example.com')
  end

  test 'uses model to check if a mail already exists' do
    model = stub('model')
    model.stubs(:mail_exists?).with('sam@example.com', 1).returns(true)
    repository = MessageRepository.new(model)
    assert repository.mail_exists?('sam@example.com', 1)
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
    repository = MessageRepository.new(model)
    message_record = stub('message_record', account: 'tom@example.com', uid: 123)
    model.stubs(:find_first).with('123').returns(message_record)
    assert_equal MessageRepository::Message.new(message_record), repository.find('123')
  end
end