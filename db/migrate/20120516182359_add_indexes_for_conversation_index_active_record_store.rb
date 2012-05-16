class AddIndexesForConversationIndexActiveRecordStore < ActiveRecord::Migration
  def change
    add_index :conversations, :identifier
    add_index :message_id_conversations, :message_id
    add_index :message_id_conversations, :conversation_id
    add_index :in_reply_to_id_conversations, :in_reply_to_id
    add_index :in_reply_to_id_conversations, :conversation_id
  end
end