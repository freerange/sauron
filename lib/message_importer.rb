class MessageImporter
  attr_reader :message_client

  def initialize(message_client)
    @message_client = message_client
  end

  def import_into(repository)
    message_client.inbox_uids.each do |uid|
      repository.store uid, message_client.inbox_message(uid)
    end
  end
end