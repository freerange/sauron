class MessageImporter
  attr_reader :message_client

  def initialize(message_client)
    @message_client = message_client
  end

  def import_into(repository)
    uids = message_client.inbox_uids
    message_client.inbox_messages(*uids).each do |message|
      repository.store(message)
    end
  end
end