class ConversationRepository
  class ConversationIndex
    class ActiveRecordStore
      class ConversationRecord < ActiveRecord::Base
        self.table_name = 'conversations'
        has_many :message_id_mappings, foreign_key: :conversation_id,
                 class_name: 'MessageIdConversation', dependent: :destroy
        has_many :in_reply_to_id_mappings, foreign_key: :conversation_id,
                 class_name: 'InReplyToIdConversation', dependent: :destroy
        has_many :participant_records, foreign_key: :conversation_id,
                 class_name: 'ConversationParticipant', dependent: :destroy

        def message_ids
          message_id_mappings.map(&:message_id)
        end

        def in_reply_to_ids
          in_reply_to_id_mappings.map(&:in_reply_to_id)
        end

        def participants
          participant_records.map(&:name)
        end
      end

      class MessageIdConversation < ActiveRecord::Base
        self.table_name = 'message_id_conversations'
        belongs_to :conversation, class_name: 'ConversationRecord'
      end

      class InReplyToIdConversation < ActiveRecord::Base
        self.table_name = 'in_reply_to_id_conversations'
        belongs_to :conversation, class_name: 'ConversationRecord'
      end

      class ConversationParticipant < ActiveRecord::Base
        belongs_to :conversation, class_name: 'ConversationRecord'
      end

      def reset!
        ConversationRecord.delete_all
        MessageIdConversation.delete_all
        InReplyToIdConversation.delete_all
        ConversationRecord.delete_all
      end

      def save(conversation)
        record = ConversationRecord.find_by_identifier(conversation.id) || ConversationRecord.new(identifier: conversation.id)
        record.update_attributes!(subject: conversation.subject, latest_message_date: conversation.latest_message_date)

        conversation.participants.each do |participant|
          record.participant_records.find_or_create_by_name(participant)
        end

        conversation.message_ids.each do |message_id|
          message_id_record = MessageIdConversation.find_or_initialize_by_message_id(message_id)
          message_id_record.update_attributes!(conversation_id: record.id)
        end

        existing_in_reply_to_records = InReplyToIdConversation.where(in_reply_to_id: conversation.in_reply_to_ids, conversation_id: record.id)
        new_in_reply_to_ids = conversation.in_reply_to_ids - existing_in_reply_to_records.map(&:in_reply_to_id)
        new_in_reply_to_ids.each { |id| InReplyToIdConversation.create!(in_reply_to_id: id, conversation_id: record.id) }
      end

      def delete(conversation)
        ConversationRecord.where(identifier: conversation.id).destroy_all
      end

      def all
        ConversationRecord.all
      end

      def find_conversation_with_message_id(message_id)
        mapping = MessageIdConversation.where(message_id: message_id).first
        Conversation.new(mapping.conversation) if mapping
      end

      def find_conversations_with_in_reply_to_id(message_id)
        InReplyToIdConversation.where(in_reply_to_id: message_id).includes(:conversation).map do |mapping|
          Conversation.new(mapping.conversation)
        end
      end
    end
  end
end
