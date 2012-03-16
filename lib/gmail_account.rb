require 'gmail_imap_client'

class GmailAccount
  class << self
    attr_accessor :email, :password
    def messages(email, password)
      new(email, password).messages
    end
  end

  def initialize(email, password)
    @imap_client = GmailImapClient.new(email, password)
  end

  def messages
    raw = @imap_client.raw_messages
    raw.map {|m| Mail.new m}
  end
end