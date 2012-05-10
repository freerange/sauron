class MessageRepository::ActiveRecordMessageIndex < ActiveRecord::Base
  self.table_name = :message_index

  has_many :mail_index_records, class_name: 'ActiveRecordMailIndex', foreign_key: :message_index_id

  def recipients
    mail_index_records.map(&:delivered_to)
  end

  class << self
    def most_recent
      all(order: "date DESC", limit: 500, group: :message_id)
    end

    def mail_exists?(account_id, uid)
      MessageRepository::ActiveRecordMailIndex.exists?(account: account_id, uid: uid)
    end

    def highest_uid(account_id)
      MessageRepository::ActiveRecordMailIndex.where(account: account_id).maximum(:uid)
    end

    def add(mail, hash)
      message_index = create!(account: mail.account, uid: mail.uid, subject: mail.subject, date: mail.date, from: mail.from, message_id: mail.message_id, message_hash: hash, delivered_to: mail.delivered_to)
      primary_message_index = find_primary_message_index_record(hash)
      MessageRepository::ActiveRecordMailIndex.create!(message_index_id: primary_message_index.id, account: mail.account, uid: mail.uid, delivered_to: mail.delivered_to)
    end

    def find_primary_message_index_record(hash)
      where(message_hash: hash).includes(:mail_index_records).order("id ASC").first
    end

    def find_by_message_id(message_id)
      where(message_id: message_id).first
    end
  end
end

