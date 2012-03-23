require 'gmail_imap_client'
require 'message_repository'

class MessageImporter

  class << self
    def import_for(email, password)
      imap_client = GmailImapClient.connect(email, password)
      new(imap_client).import_into(MessageRepository.instance)
    end
  end

  attr_reader :message_client

  def initialize(message_client)
    @message_client = message_client
  end

  def import_into(repository)
    message_client.inbox_messages.each do |message|
      repository.store(message)
    end
  end
end