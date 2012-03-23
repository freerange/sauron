require 'test_helper'
require 'fileutils'

class FileBasedMessageStoreTest < ActiveSupport::TestCase
  TEST_ROOT_PATH = File.expand_path('tmp/test/data')

  setup do
    FileUtils.mkdir_p TEST_ROOT_PATH
  end

  test 'determines path to store keys using root path and MD5 hash of key' do
    hash = Digest::MD5.hexdigest('message-key')
    FileBasedMessageStore.new(TEST_ROOT_PATH)['message-key'] = 'something'
  end

  test 'stores messages persistently on the filesystem' do
    FileBasedMessageStore.new(TEST_ROOT_PATH)['x'] = 'y'
    assert_equal 'y', FileBasedMessageStore.new(TEST_ROOT_PATH)['x']
    FileUtils.rm_rf TEST_ROOT_PATH
    assert_nil FileBasedMessageStore.new(TEST_ROOT_PATH)['x']
  end

  test 'creates storage directory if it doesn\'t already exist' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    FileUtils.rm_rf 'tmp/test'
    store['x'] = 'y'
    assert File.directory?(TEST_ROOT_PATH)
  end

  test 'encodes messages to avoid problems with strange encodings' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    store['strange'] = "\xA3"
    assert_equal "\xA3", store['strange']
  end

  test 'indicates if a key has already been stored' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    refute store.include?('a')
    store['a'] = 'b'
    assert store.include?('a')
  end

  test 'provides access to all messages stored' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    store['a'] = '1'
    store['b'] = '2'
    assert_equal ['1', '2'], store.values.sort
  end

  teardown do
    FileUtils.rm_rf TEST_ROOT_PATH
  end
end
