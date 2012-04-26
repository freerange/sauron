class RenameActiveRecordIndexesTable < ActiveRecord::Migration
  def change
    rename_table :messages, :mail_index
  end
end