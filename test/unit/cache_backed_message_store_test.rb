require 'test_helper'

class CacheBackedMessageStoreTest < ActiveSupport::TestCase
  test 'writes the raw message to its cache, using the uid and account as a key' do
    cache = stub('cache')
    store = CacheBackedMessageStore.new(cache)
    message = stub('messaghe', account: 'jim@example.com', uid: 234, raw: 'raw-message')
    cache.expects(:write).with(['jim@example.com', 234], 'raw-message')
    store.add message
  end

  test 'reads raw message from the cache given a uid and account' do
    cache = stub('cache')
    store = CacheBackedMessageStore.new(cache)
    cache.stubs(:read).with(['bob@example.com', 195]).returns('read-raw-message')
    assert_equal 'read-raw-message', store.find('bob@example.com', 195)
  end
end