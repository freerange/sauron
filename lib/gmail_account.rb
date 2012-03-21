class GmailAccount
  class << self
    attr_accessor :email, :password
    def messages(email, password)
      new(email, password).messages
    end
  end

  def initialize(email, password, imap_client = nil)
    @imap_client = imap_client || GmailImapClient.connect(email, password)
  end

  def messages
    raw = @imap_client.inbox_messages
    raw.map {|m| Mail.new m}
  end
end