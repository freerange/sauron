class AddParticipantsToConversation < ActiveRecord::Migration
  def change
    create_table :conversation_participants, :force => true do |t|
      t.string :name
      t.references :conversation
      t.timestamps
    end
  end
end