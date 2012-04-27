require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'uses MessageRepository::ActiveRecordMailIndex as default index' do
    index = stub('index')
    assert_equal MessageRepository::ActiveRecordMailIndex, MessageRepository.new.mail_index
  end

  test 'uses CacheBackedMailStore as default store' do
    index = stub('index')
    assert_equal CacheBackedMailStore, MessageRepository.new.mail_store
  end

  test 'adds mail to record index with a hash of the message ID' do
    index = stub('index')
    store = stub('store', add: nil)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: '<abc123@example.com>')
    repository = MessageRepository.new(index, store)
    index.expects(:add).with(mail, Digest::SHA1.hexdigest('<abc123@example.com>'))
    repository.add_mail(mail)
  end

  test 'adds mail to record index with a hash of date, subject and recipients if message_id is missing' do
    index = stub('index')
    store = stub('store', add: nil)
    now = Time.now
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: nil, from: ['bob'], date: now, subject: 'Hello')
    repository = MessageRepository.new(index, store)
    index.expects(:add).with(mail, Digest::SHA1.hexdigest('bob' + now.to_s + 'Hello'))
    repository.add_mail(mail)
  end

  test 'adds mail to record index with a hash when subject is missing' do
    index = stub('index')
    store = stub('store', add: nil)
    now = Time.now
    repository = MessageRepository.new(index, store)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: nil, from: ['bob'], date: now, subject: nil)
    index.expects(:add).with(mail, Digest::SHA1.hexdigest('bob' + now.to_s))
    repository.add_mail(mail)
  end

  test 'adds mail to record index with a hash when date is missing' do
    index = stub('index')
    store = stub('store', add: nil)
    repository = MessageRepository.new(index, store)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: nil, from: ['bob'], date: nil, subject: 'Hello')
    index.expects(:add).with(mail, Digest::SHA1.hexdigest('bob' + 'Hello'))
    repository.add_mail(mail)
  end

  test 'adds mail to record index with a hash when sender is missing' do
    index = stub('index')
    store = stub('store', add: nil)
    now = Time.now
    repository = MessageRepository.new(index, store)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: nil, from: [], date: now, subject: 'Hello')
    index.expects(:add).with(mail, Digest::SHA1.hexdigest(now.to_s + 'Hello'))
    repository.add_mail(mail)
  end

  test 'adds mail to record index with a hash when date and subject and sender are missing' do
    index = stub('index')
    store = stub('store', add: nil)
    repository = MessageRepository.new(index, store)
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: nil, from: [], date: nil, subject: nil)
    index.expects(:add).with(mail, Digest::SHA1.hexdigest(''))
    repository.add_mail(mail)
  end
  test 'adds mail to message store' do
    index = stub('index', add: nil)
    store = stub('store')
    mail = stub('mail', account: 'sam@example.com', uid: 123, raw: 'raw-message', message_id: '<abc123@example.com>')
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
    index.stubs(:find_first_by_message_hash).with('message-hash').returns(index_record)
    assert_equal MessageRepository::Message.new(index_record, store), repository.find('message-hash')
  end
end