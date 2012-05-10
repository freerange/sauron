class MessageRepository::ActiveRecordMessageIndex < ActiveRecord::Base
  self.table_name = :message_index

  has_many :mail_index_records, class_name: 'ActiveRecordMailIndex', foreign_key: :message_index_id

  def recipients
    mail_index_records.map(&:delivered_to)
  end

  def mail_identifier
    [mail_index_records.first.account, mail_index_records.first.uid]
  end

  class << self
    def most_recent
      all(order: "date DESC", limit: 500)
    end

    def mail_exists?(account_id, uid)
      MessageRepository::ActiveRecordMailIndex.exists?(account: account_id, uid: uid)
    end

    def highest_uid(account_id)
      MessageRepository::ActiveRecordMailIndex.where(account: account_id).maximum(:uid)
    end

    def add(mail, hash)
      unless message_index_record = find_by_message_hash(hash)
        message_index_record = create!(subject: mail.subject, date: mail.date, from: mail.from, message_id: mail.message_id, message_hash: hash)
      end
      MessageRepository::ActiveRecordMailIndex.create!(message_index_id: message_index_record.id, account: mail.account, uid: mail.uid, delivered_to: mail.delivered_to)
    end

    def find_by_message_hash(hash)
      where(message_hash: hash).includes(:mail_index_records).first
    end
  end
end

