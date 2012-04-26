require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses MailRepository::ActiveRecordMailIndex as default index' do
    index = stub('index')
    assert_equal MailRepository::ActiveRecordMailIndex, MessageRepository.new.mail_index
  end

  test 'uses MailRepository::CacheBackedMailStore as default store' do
    index = stub('index')
    assert_equal CacheBackedMailStore, MessageRepository.new.mail_store
  end

  test 'adds mail to record index' do
    index = stub('index')
    store = stub('store', add: nil)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message')
    repository = MessageRepository.new(index, store)
    index.expects(:add).with(mail)
    repository.add_mail(mail)
  end

  test 'adds mail to message store' do
    index = stub('index', add: nil)
    store = stub('store')
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message')
    repository = MessageRepository.new(index, store)
    store.expects(:add).with(mail)
    repository.add_mail(mail)
  end

  test 'uses index to obtain highest mail uid for account' do
    index = stub('index')
    index.stubs(:highest_uid).with('sam@example.com').returns(999)
    repository = MessageRepository.new(index)
    assert_equal 999, repository.highest_mail_uid('sam@example.com')
  end

  test 'uses index to check if a mail already exists' do
    index = stub('index')
    index.stubs(:mail_exists?).with('sam@example.com', 1).returns(true)
    repository = MessageRepository.new(index)
    assert repository.mail_exists?('sam@example.com', 1)
  end

  test 'retrieves the most recent messages from the index' do
    index = stub('index')
    store = stub('store', find: '')
    repository = MessageRepository.new(index, store)
    index_record = stub('index_record', account: 'tom@example.com', uid: 123)
    index.stubs(:most_recent).returns([index_record])
    assert_equal [MessageRepository::Message.new(index_record, store)], repository.messages
  end

  test 'finds a single message from the index' do
    index = stub('index')
    store = stub('store', find: '')
    repository = MessageRepository.new(index, store)
    index_record = stub('index_record', account: 'tom@example.com', uid: 123)
    index.stubs(:find_first).with('123').returns(index_record)
    assert_equal MessageRepository::Message.new(index_record, store), repository.find('123')
  end
end