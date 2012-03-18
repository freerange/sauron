require "net/imap"
require 'mail'

class GmailImapClient
  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def raw_messages
    connection.select 'INBOX'
    connection.uid_search('ALL').map {|uid| connection.uid_fetch(uid, 'BODY.PEEK[]')[0].attr['BODY[]']}
  end

  class << self
    def connect(email, password)
      connection = Net::IMAP.new('imap.gmail.com', 993, ssl=true)
      connection.login(email, password)
      new connection
    end
  end
end