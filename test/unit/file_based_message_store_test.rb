require 'test_helper'
require 'fileutils'

class FileBasedMessageStoreTest < ActiveSupport::TestCase
  TEST_ROOT_PATH = File.expand_path('tmp/test/data')

  setup do
    FileUtils.mkdir_p TEST_ROOT_PATH
  end

  test 'determines path to store keys using root path and MD5 hash of key' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    hash = Digest::MD5.hexdigest('1')
    assert_equal File.expand_path(File.join('tmp/test/data', hash)), store.key_path(1)
  end

  test 'stores messages in the path for the given key' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    store['x'] = 'y'
    assert_equal 'y', File.read(store.key_path('x'))
  end

  test 'stores messages successfully whether directory exists or not' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    FileUtils.rm_rf 'tmp/test'
    store['x'] = 'y'
    assert_equal 'y', File.read(store.key_path('x'))
  end

  test 'indicates if a key has already been stored' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    refute store.include?('a')
    store['a'] = 'b'
    assert store.include?('a')
  end

  test 'provides access to all messages stored' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    File.write(store.key_path('a'), '1')
    File.write(store.key_path('b'), '2')
    assert_equal ['1', '2'], store.values.sort
  end

  teardown do
    FileUtils.rm_rf TEST_ROOT_PATH
  end
end
