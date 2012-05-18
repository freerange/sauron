class ConversationRepository
  class Conversation
    attr_reader :id, :subject, :latest_message_date, :message_ids, :in_reply_to_ids, :participants

    def initialize(storage_record=nil)
      if storage_record
        @message_ids = storage_record.message_ids
        @in_reply_to_ids = storage_record.in_reply_to_ids
        @participants = storage_record.participants
        @id = storage_record.identifier
        @subject = storage_record.subject
        @latest_message_date = storage_record.latest_message_date
      else
        @message_ids = []
        @in_reply_to_ids = []
        @participants = []
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
      @participants << message.from
    end

    def merge(other_conversation)
      @message_ids += other_conversation.message_ids
      @in_reply_to_ids += other_conversation.in_reply_to_ids
      if @latest_message_date < other_conversation.latest_message_date
        @subject = other_conversation.subject
        @latest_message_date = other_conversation.latest_message_date
      end
      @participants += other_conversation.participants
      self
    end

    def ==(other_conversation)
      other_conversation.id == id
    end

    extend ActiveModel::Naming

    def to_param
      id
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, "Conversation")
    end
  end
end
