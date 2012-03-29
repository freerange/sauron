module GoogleMail
  class ImapCache
    delegate :read, :write, :fetch, to: :@cache

    def initialize(cache = ActiveSupport::Cache::FileStore.new(Rails.root + 'tmp' + 'cache' + 'imap'))
      @cache = cache
    end

    class << self
      delegate :read, :write, :fetch, to: :instance

      def instance
        @instance ||= new
      end

      def configure(*args)
        @instance = new(*args)
      end
    end
  end
end