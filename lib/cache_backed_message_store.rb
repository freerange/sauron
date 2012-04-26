class CacheBackedMessageStore
  def initialize(cache = ActiveSupport::Cache::FileStore.new(Rails.root + 'data' + Rails.env + 'messages'))
    @cache = cache
  end

  def add(message)
    @cache.write [message.account, message.uid], message.raw
  end

  def find(account, uid)
    @cache.read [account, uid]
  end

  class << self
    delegate :add, :find, to: :instance

    def instance
      @instance ||= new
    end

    def configure(*args)
      @instance = new(*args)
    end
  end
end