require 'message_repository'

class AccountMailImporter
  class << self
    def import_for(email, password)
      Rails.logger.info("Importing mails for account #{email}")
      mailbox = GoogleMail::Mailbox.connect(email, password)
      importer = MailImporter.new(mailbox)
      importer.import_into(MessageRepository, ConversationRepository)
    end
  end
end