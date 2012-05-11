class AddInReplyToToMessageIndex < ActiveRecord::Migration
  def change
    add_column :message_index, :in_reply_to, :string
    add_index :message_index, :in_reply_to
  end
end