require "net/imap"
require 'mail'

class GmailImapClient
  def initialize(email, password)
    @imap = Net::IMAP.new('imap.gmail.com', 993, ssl=true)
    @imap.login(email, password)
  end

  def raw_messages
    @imap.select 'INBOX'
    @imap.uid_search('ALL').map {|uid| @imap.uid_fetch(uid, 'BODY.PEEK[]')[0].attr['BODY[]']}
  end
end