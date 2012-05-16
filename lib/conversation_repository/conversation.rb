class ConversationRepository
  class Conversation
    attr_reader :id, :subject, :latest_message_date, :message_ids, :in_reply_to_ids
    def initialize(storage_record=nil, message_ids=[], in_reply_to_ids=[])
      @message_ids = message_ids
      @in_reply_to_ids = in_reply_to_ids
      if storage_record
        @id = storage_record.identifier
        @subject = storage_record.subject
        @latest_message_date = storage_record.latest_message_date
      else
        @id = SecureRandom.hex
        @latest_message_date = Time.at(0)
      end
    end
    def add_message(message)
      @message_ids << message.message_id
      @in_reply_to_ids << message.in_reply_to if message.in_reply_to
      if message.date > latest_message_date
        @subject = message.subject
        @latest_message_date = message.date
      end
    end
    def merge(other_conversation)
      @message_ids += other_conversation.message_ids
      @in_reply_to_ids += other_conversation.in_reply_to_ids
      if @latest_message_date < other_conversation.latest_message_date
        @subject = other_conversation.subject
        @latest_message_date = other_conversation.latest_message_date
      end
      self
    end
  end
end
