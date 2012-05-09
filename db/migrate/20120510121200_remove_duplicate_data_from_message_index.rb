class RemoveDuplicateDataFromMessageIndex < ActiveRecord::Migration
  def up
    delete "DELETE FROM message_index WHERE id NOT IN (SELECT DISTINCT(message_index_id) FROM mail_index)"
  end

  def down
    # intentionally left blank
  end
end
