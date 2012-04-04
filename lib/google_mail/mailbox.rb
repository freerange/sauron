require 'net/imap'

module GoogleMail
  class Mailbox
    class AuthenticatedConnection
      attr_reader :email
      delegate :examine, :uid_search, :list, :uid_fetch, to: :@imap

      def initialize(email, password)
        @imap = ::Net::IMAP.new 'imap.gmail.com', 993, true
        @imap.login email, password
        @email = email
      end
    end

    class CachedConnection
      delegate :email, :examine, :uid_search, :list, to: :@connection

      def initialize(email, password, cache = GoogleMail::ImapCache)
        @connection = AuthenticatedConnection.new(email, password)
        @cache = cache
      end

      def uid_fetch(uid, command)
        @cache.fetch [@connection.email, uid, command] do
          @connection.uid_fetch(uid, command)
        end
      end
    end

    cattr_accessor :connection_class
    self.connection_class = CachedConnection

    attr_reader :connection
    delegate :email, to: :connection

    def initialize(connection)
      @connection = connection
      mailboxes = @connection.list('', '%').collect(&:name)
      if mailboxes.include?('[Gmail]')
        @connection.examine '[Gmail]/All Mail'
      else
        @connection.examine '[Google Mail]/All Mail'
      end
    end

    def each_uid(&block)
      connection.uid_search('ALL').each(&block)
    end

    def message(uid)
      connection.uid_fetch(uid, 'BODY.PEEK[]').map {|m| m.attr['BODY[]']}.first
    end

    class << self
      def connect(email, password)
        new connection_class.new(email, password)
      end
    end
  end
end