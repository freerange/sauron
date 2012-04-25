class MessageRepository::Record < ActiveRecord::Base
  self.table_name = :messages

  class << self
    def most_recent
      all(order: "date DESC", limit: 2500)
    end

    def message_exists?(account_id, uid)
      exists?(account: account_id, uid: uid)
    end

    def highest_uid(account_id)
      where(account: account_id).maximum(:uid)
    end
  end
end