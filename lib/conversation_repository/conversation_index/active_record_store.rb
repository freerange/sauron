class ConversationRepository
  class ConversationIndex
    class ActiveRecordStore
      class ConversationRecord < ActiveRecord::Base
        self.table_name = 'conversations'
        has_many :message_id_mappings, foreign_key: :conversation_id,
                 class_name: 'MessageIdConversation', dependent: :destroy
        has_many :in_reply_to_id_mappings, foreign_key: :conversation_id,
                 class_name: 'InReplyToIdConversation', dependent: :destroy
      end

      class MessageIdConversation < ActiveRecord::Base
        self.table_name = 'message_id_conversations'
        belongs_to :conversation, class_name: 'ConversationRecord'
      end

      class InReplyToIdConversation < ActiveRecord::Base
        self.table_name = 'in_reply_to_id_conversations'
        belongs_to :conversation, class_name: 'ConversationRecord'
      end

      def save(conversation)
        record = ConversationRecord.find_by_identifier(conversation.id) || ConversationRecord.new(identifier: conversation.id)
        record.update_attributes!(subject: conversation.subject, latest_message_date: conversation.latest_message_date)

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
        conversation_from_mapping(mapping) if mapping
      end

      def find_conversations_with_in_reply_to_id(message_id)
        InReplyToIdConversation.where(in_reply_to_id: message_id).includes(:conversation).map do |mapping|
          conversation_from_mapping(mapping)
        end
      end

      private

      def conversation_from_mapping(mapping)
        message_ids = MessageIdConversation.where(conversation_id: mapping.conversation_id).map(&:message_id)
        in_reply_to_ids = InReplyToIdConversation.where(conversation_id: mapping.conversation_id).map(&:in_reply_to_id)
        Conversation.new(mapping.conversation, message_ids, in_reply_to_ids)
      end
    end
  end
end
