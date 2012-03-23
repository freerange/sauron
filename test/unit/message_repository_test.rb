require 'test_helper'

class MessageRepositoryTest < ActiveSupport::TestCase
  test 'delegates key generation to a MessageRepository::KeyGenerator by default' do
    key_generator = stub('key-generator')
    MessageRepository::KeyGenerator.expects(:new).returns(key_generator)
    repository = MessageRepository.new(stub_everything)
    key_generator.stubs(:key_for).with(:message).returns(:standard_generated_key)
    assert_equal :standard_generated_key, repository.key_for(:message)
  end

  test 'allows different key generators to be injected' do
    key_generator = stub('key-generator')
    repository = MessageRepository.new(stub_everything, key_generator)
    key_generator.stubs(:key_for).with(:message).returns(:custom_key)
    assert_equal :custom_key, repository.key_for(:message)
  end

  test 'stores messages in message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)

    message = stub('message')
    repository.stubs(:key_for).with(123).returns('123')
    store.expects(:[]=).with('123', message)
    repository.store(123, message)
  end

  test 'indicates if a message exists in message store' do
    store = stub('message-store')
    repository = MessageRepository.new(store)
    store.stubs(:include?).with(repository.key_for(1)).returns(true)
    store.stubs(:include?).with(repository.key_for(2)).returns(false)
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

class MessageRepository::KeyGeneratorTest < ActiveSupport::TestCase
  test 'generates keys by calculating MD5 hash' do
    generator = MessageRepository::KeyGenerator.new
    hash = Digest::MD5.hexdigest(1.to_s)
    assert_equal hash, generator.key_for(1)
  end
end
