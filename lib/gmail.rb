require "net/imap"
require 'mail'

class Gmail
  class << self
    attr_accessor :email, :password
    def messages(email, password)
      new(email, password).messages
    end
  end
  
  def initialize(email, password)
    @imap = Net::IMAP.new('imap.gmail.com', 993, ssl=true)
    @imap.login(email, password)
  end

  def messages
    raw = retrieve_raw_messages
    raw.map {|m| Mail.new m}
  end

  def retrieve_raw_messages
    @imap.select 'INBOX'
    @imap.uid_search('ALL').map {|uid| @imap.uid_fetch(uid, 'BODY.PEEK[]')[0].attr['BODY[]']}
  end
end