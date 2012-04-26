class MailRepository::ActiveRecordMailIndex < ActiveRecord::Base
  self.table_name = :mail_index

  class << self
    def most_recent
      all(order: "date DESC", limit: 500, group: :message_id)
    end

    def mail_exists?(account_id, uid)
      exists?(account: account_id, uid: uid)
    end

    def highest_uid(account_id)
      where(account: account_id).maximum(:uid)
    end

    def find_first(id)
      where(id: id).first
    end

    def add(mail)
      create! account: mail.account, uid: mail.uid, subject: mail.subject, date: mail.date, from: mail.from, message_id: mail.message_id
    end
  end
end