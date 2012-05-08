class CreateAndPopulateMailIndex < ActiveRecord::Migration
  class MessageIndexTable < ActiveRecord::Base
    self.table_name = :message_index
  end
  class MailIndexTable < ActiveRecord::Base
    self.table_name = :mail_index
  end

  def up
    create_table :mail_index, :force => true do |t|
      t.references :message_index
      t.string :account
      t.string :uid
      t.string :delivered_to
      t.timestamps
    end
    add_index :mail_index, :message_index_id

    MessageIndexTable.find_each do |message|
      primary_message = MessageIndexTable.where(message_hash: message.message_hash).order("id ASC").first
      MailIndexTable.create!(
        message_index_id: primary_message.id,
        account: message.account,
        uid: message.uid,
        delivered_to: message.delivered_to
      )
    end
  end

  def down
    drop_table :mail_index
  end
end
