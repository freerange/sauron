require "net/imap"
require 'mail'

class GmailImapClient
  class Connection
    attr_reader :imap
    delegate :login, :select, :uid_search, :uid_fetch, to: :imap

    def initialize(email, password)
      @imap = ::Net::IMAP.new('imap.gmail.com', 993, ssl=true)
      login(email, password)
    end

    def select(*args)
      # Method delegation fails for select as it's already defined in Object.  Changing
      # Connection to be a subclass of BasicObject breaks mocha
      @imap.select(*args)
    end
  end

  cattr_accessor :connection_class
  self.connection_class = Connection

  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def inbox_messages
    connection.select 'INBOX'
    uids = connection.uid_search('ALL')
    connection.uid_fetch(uids, 'BODY.PEEK[]').map {|m| m.attr['BODY[]']}
  end

  class << self
    def connect(email, password)
      new connection_class.new(email, password)
    end
  end
end