require 'message_repository'

class AccountMessageImporter
  class << self
    def import_for(email, password)
      Rails.logger.info("Importing messages for account #{email}")
      mailbox = GoogleMail::Mailbox.connect(email, password)
      MessageImporter.new(mailbox).import_into(MessageRepository)
    end
  end
end