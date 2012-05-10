class RemoveRedundantColumnsFromMessageIndex < ActiveRecord::Migration
  def change
    remove_column :message_index, :account
    remove_column :message_index, :uid
    remove_column :message_index, :delivered_to
  end
end
