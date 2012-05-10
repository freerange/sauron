class ChangeMailIndexUidToInteger < ActiveRecord::Migration
  def change
    change_column :mail_index, :uid, :integer
  end
end