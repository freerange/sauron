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
      unless primary_message_index = find_primary_message_index_record(hash)
        primary_message_index = create!(subject: mail.subject, date: mail.date, from: mail.from, message_id: mail.message_id, message_hash: hash)
      end
      MessageRepository::ActiveRecordMailIndex.create!(message_index_id: primary_message_index.id, account: mail.account, uid: mail.uid, delivered_to: mail.delivered_to)
    end

    def find_primary_message_index_record(hash)
      where(message_hash: hash).includes(:mail_index_records).order("id ASC").first
    end
  end
end

