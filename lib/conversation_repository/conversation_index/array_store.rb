class ConversationRepository
  class ConversationIndex
    class ArrayStore
      def initialize
        @store = []
      end
      def save(conversation)
        delete(conversation)
        @store << conversation
      end
      def delete(conversation)
        @store.delete_if { |c| c.id == conversation.id }
      end
      def all
        @store
      end
      def find_conversation_with_message_id(message_id)
        @store.find { |c| c.message_ids.include?(message_id) }
      end
      def find_conversations_with_in_reply_to_id(message_id)
        @store.select { |c| c.in_reply_to_ids.include?(message_id) }
      end
    end
  end
end
