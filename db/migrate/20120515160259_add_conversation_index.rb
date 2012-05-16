class AddConversationIndex < ActiveRecord::Migration
  def change
    create_table :conversations, :force => true do |t|
      t.string :identifier
      t.string :subject
      t.datetime :latest_message_date
      t.timestamps
    end

    create_table :message_id_conversations, :force => true do |t|
      t.string :message_id
      t.references :conversation
      t.timestamps
    end

    create_table :in_reply_to_id_conversations, :force => true do |t|
      t.string :in_reply_to_id
      t.references :conversation
      t.timestamps
    end
  end
end
