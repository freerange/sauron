class ChangeMessagesUidToInteger < ActiveRecord::Migration
  def change
    change_column :messages, :uid, :integer
  end
end