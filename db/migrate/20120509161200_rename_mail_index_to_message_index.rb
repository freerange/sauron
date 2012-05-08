class RenameMailIndexToMessageIndex < ActiveRecord::Migration
  def change
    rename_table :mail_index, :message_index
  end
end