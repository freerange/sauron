class ConversationRepository
  class ConversationIndex
    def initialize(implementation = ActiveRecordStore.new)
      @implementation = implementation
    end

    def add(message)
      return if message_exists?(message)
      if conversation = find_conversation_for(message)
        conversation.add_message(message)
        @implementation.save(conversation)
      else
        conversation = Conversation.new
        conversation.add_message(message)
        @implementation.save(conversation)
      end
      if (other_conversations = find_conversations_with_replies_to(message)).any?
        other_conversations.each do |other_conversation|
          conversation.merge(other_conversation)
          @implementation.delete(other_conversation)
          @implementation.save(conversation)
        end
      end
      conversation
    end

    def message_exists?(message)
      @implementation.find_conversation_with_message_id(message.message_id).present?
    end

    def find(id)
      record = @implementation.find_conversation_by_id(id)
      Conversation.new(record) if record
    end

    def most_recent
      @implementation.all.map { |record| Conversation.new(record) }
    end

    private

    def find_conversation_for(message)
      record = @implementation.find_conversation_with_message_id(message.in_reply_to)
      Conversation.new(record) if record
    end

    def find_conversations_with_replies_to(message)
      @implementation.find_conversations_with_in_reply_to_id(message.message_id).map do |record|
        Conversation.new(record)
      end
    end
  end
end
