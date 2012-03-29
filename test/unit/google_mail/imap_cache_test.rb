require 'test_helper'

module GoogleMail
  class ImapCacheTest < ActiveSupport::TestCase
    test 'delegates read, write and fetch to the underlying cache' do
      underlying_cache = stub('cache', read: :read_result, write: :write_result, fetch: :fetch_result)
      cache = ImapCache.new(underlying_cache)
      assert_equal :read_result, cache.read
      assert_equal :write_result, cache.write
      assert_equal :fetch_result, cache.fetch
    end
  end
end