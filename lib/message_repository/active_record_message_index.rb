class MessageRepository::ActiveRecordMessageIndex < ActiveRecord::Base
  self.table_name = :messages

  class << self
    def most_recent
      all(order: "date DESC", limit: 2500, group: [:subject, :date, :message_id])
    end

    def message_exists?(account_id, uid)
      exists?(account: account_id, uid: uid)
    end

    def highest_uid(account_id)
      where(account: account_id).maximum(:uid)
    end

    def add(message)
      create! account: message.account, uid: message.uid, subject: message.subject, date: message.date, from: message.from, message_id: message.message_id
    end
  end
end