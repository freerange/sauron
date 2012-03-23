require 'gmail_imap_client'
require 'message_repository'

class AccountMessageImporter
  class << self
    def import_for(email, password)
      imap_client = GmailImapClient.connect(email, password)
      MessageImporter.new(imap_client).import_into(MessageRepository.instance)
    end
  end
end