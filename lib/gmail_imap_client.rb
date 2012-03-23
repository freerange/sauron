require 'net/imap'

class GmailImapClient
  class AuthenticatedConnection
    delegate :examine, :uid_search, :list, :uid_fetch, to: :@imap

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
    mailboxes = @connection.list('', '%').collect(&:name)
    if mailboxes.include?('[Gmail]')
      @connection.examine '[Gmail]/All Mail'
    else
      @connection.examine '[Google Mail]/All Mail'
    end
  end

  def inbox_uids
    connection.uid_search('ALL')
  end

  def inbox_message(uid)
    inbox_messages(uid).first
  end

  def inbox_messages(*uids)
    connection.uid_fetch(uids, 'BODY.PEEK[]').map {|m| m.attr['BODY[]']}
  end

  class << self
    def connect(email, password)
      new connection_class.new(email, password)
    end
  end
end