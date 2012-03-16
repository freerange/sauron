require "net/imap"
require 'mail'

class GmailImapClient
  class NotConnectedError < RuntimeError; end

  def initialize
    @imap = Net::IMAP.new('imap.gmail.com', 993, ssl=true)
  end

  def connect_as(email, password)
    @imap.login(email, password)
    @connected = true
  end

  def raw_messages
    raise NotConnectedError unless @connected
    @imap.select 'INBOX'
    @imap.uid_search('ALL').map {|uid| @imap.uid_fetch(uid, 'BODY.PEEK[]')[0].attr['BODY[]']}
  end
end