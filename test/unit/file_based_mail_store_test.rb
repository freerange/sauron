require 'test_helper'
require 'fileutils'

class FileBasedMailStoreTest < ActiveSupport::TestCase
  TEST_ROOT_PATH = File.expand_path('tmp/test/data')

  setup do
    FileUtils.mkdir_p TEST_ROOT_PATH
  end

  test 'uses "data/<Rails.env>/messages" as its default root path' do
    assert_equal Rails.root + 'data' + 'test' + 'messages', FileBasedMailStore.new.root_path
  end

  test 'determines path to store keys using root path and MD5 hash of key' do
    hash = Digest::MD5.hexdigest('message-key')
    FileBasedMailStore.new(TEST_ROOT_PATH)['message-key'] = 'something'
  end

  test 'stores messages persistently on the filesystem' do
    FileBasedMailStore.new(TEST_ROOT_PATH)['x'] = 'y'
    assert_equal 'y', FileBasedMailStore.new(TEST_ROOT_PATH)['x']
    FileUtils.rm_rf TEST_ROOT_PATH
    assert_nil FileBasedMailStore.new(TEST_ROOT_PATH)['x']
  end

  test 'creates storage directory if it doesn\'t already exist' do
    store = FileBasedMailStore.new(TEST_ROOT_PATH)
    FileUtils.rm_rf 'tmp/test'
    store['x'] = 'y'
    assert File.directory?(TEST_ROOT_PATH)
  end

  test 'encodes messages to avoid problems with strange encodings' do
    store = FileBasedMailStore.new(TEST_ROOT_PATH)
    string_with_unknown_encoding = "\xA3".force_encoding("ascii-8bit")
    store['strange'] = string_with_unknown_encoding
    assert_equal string_with_unknown_encoding, store['strange']
  end

  test 'indicates if a key has already been stored' do
    store = FileBasedMailStore.new(TEST_ROOT_PATH)
    refute store.include?('a')
    store['a'] = 'b'
    assert store.include?('a')
  end

  test 'provides access to all messages stored' do
    store = FileBasedMailStore.new(TEST_ROOT_PATH)
    store['a'] = '1'
    store['b'] = '2'
    assert_same_elements ['1', '2'], store.values
  end

  teardown do
    FileUtils.rm_rf TEST_ROOT_PATH
  end
end
