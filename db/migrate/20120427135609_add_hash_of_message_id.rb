class AddHashOfMessageId < ActiveRecord::Migration
  def change
    add_column :mail_index, :message_hash, :string
  end
end