require 'message_repository'

class AccountMessageImporter
  class << self
    def import_for(email, password)
      mailbox = GoogleMail::Mailbox.connect(email, password)
      MessageImporter.new(mailbox).import_into(MessageRepository)
    end
  end
end