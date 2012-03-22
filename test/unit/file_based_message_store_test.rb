require 'test_helper'
require 'fileutils'

class FileBasedMessageStoreTest < ActiveSupport::TestCase
  TEST_ROOT_PATH = File.expand_path('tmp/test/data')

  setup do
    FileUtils.mkdir_p TEST_ROOT_PATH
  end

  test 'stores messages in given root path' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    store['x'] = 'y'
    assert_equal 'y', File.read(File.expand_path('x', TEST_ROOT_PATH))
  end

  test 'stores messages successfully when directory doesn\'t exist beforehand' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    FileUtils.rm_rf 'tmp/test'
    store['x'] = 'y'
    assert File.directory?('tmp/test/data')
  end

  test 'retrieves all messages from its root path' do
    store = FileBasedMessageStore.new(TEST_ROOT_PATH)
    File.write(File.expand_path('a', TEST_ROOT_PATH), '1')
    File.write(File.expand_path('b', TEST_ROOT_PATH), '2')
    assert_equal ['1', '2'], store.values.sort
  end

  teardown do
    FileUtils.rm_rf TEST_ROOT_PATH
  end
end
