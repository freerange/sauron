# encoding: utf-8
require 'mail'

class MessageRepository
  class << self
    attr_writer :instance

    delegate :highest_mail_uid, :find, :add_mail, :mail_exists?, :messages, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :mail_index, :mail_store

  def initialize(mail_index = MailRepository::ActiveRecordMailIndex, mail_store = CacheBackedMailStore)
    @mail_index = mail_index
    @mail_store = mail_store
  end

  def highest_mail_uid(account)
    mail_index.highest_uid(account)
  end

  def add_mail(mail)
    hash = if mail.message_id
      Digest::SHA1.hexdigest(mail.message_id)
    else
      Digest::SHA1.hexdigest(mail.from.join + mail.date.to_s + mail.subject)
    end
    mail_index.add mail, hash
    mail_store.add mail
  end

  def mail_exists?(account, uid)
    mail_index.mail_exists?(account, uid)
  end

  def find(message_hash)
    record = mail_index.find_first_by_message_hash(message_hash)
    record && Message.new(record, mail_store)
  end

  def messages
    mail_index.most_recent.map do |record|
      Message.new(record, mail_store)
    end
  end
end

