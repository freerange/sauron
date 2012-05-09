class AddIndexToMessageHashOnMailIndex < ActiveRecord::Migration
  def change
    add_index :mail_index, :message_hash
  end
end