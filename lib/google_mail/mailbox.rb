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

    class Mail
      attr_reader :account, :uid, :raw, :wrapper
      delegate :from, :subject, :date, :message_id, to: :wrapper

      def initialize(account, uid, raw)
        @account = account
        @uid = uid
        @raw = raw
        @wrapper = MailWrapper.new(raw)
      end

      def ==(mail)
        mail.is_a?(self.class) && mail.account == account && mail.uid == uid && mail.raw == raw
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

    def uids(from_uid = nil)
      if from_uid.nil?
        connection.uid_search('ALL')
      else
        connection.uid_search("UID #{from_uid}:*")
      end
    end

    def raw_mail(uid)
      begin
        response = connection.uid_fetch(uid, 'BODY.PEEK[]')
        if response
          response.map {|m| m.attr['BODY[]']}.first
        else
          response = connection.uid_fetch(uid, '(BODY.PEEK[HEADER] BODY.PEEK[TEXT])')
          response.first.attr['BODY[HEADER]'] + response.first.attr['BODY[TEXT]']
        end
      rescue Net::IMAP::NoResponseError
        response = connection.uid_fetch(uid, 'BODY.PEEK[HEADER]')
        response.first.attr['BODY[HEADER]'] + '\n\nThis mail could not be downloaded from the server'
      end
    end

    def mail(uid)
      Mailbox::Mail.new(email, uid, raw_mail(uid))
    end

    class << self
      def connect(email, password)
        new connection_class.new(email, password)
      end
    end
  end
end