class MessageImporter
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