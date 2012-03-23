require 'net/imap'

class GmailImapClient
  class AuthenticatedConnection
    delegate :examine, :uid_search, :uid_fetch, to: :@imap

    def initialize(email, password)
      @imap = ::Net::IMAP.new 'imap.gmail.com', 993, true
      @imap.login email, password
    end
  end

  cattr_accessor :connection_class
  self.connection_class = AuthenticatedConnection

  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def inbox_uids
    connection.examine 'INBOX'
    connection.uid_search('ALL')
  end

  def inbox_messages(*uids)
    connection.examine 'INBOX'
    connection.uid_fetch(uids, 'BODY.PEEK[]').map {|m| m.attr['BODY[]']}
  end

  class << self
    def connect(email, password)
      new connection_class.new(email, password)
    end
  end
end