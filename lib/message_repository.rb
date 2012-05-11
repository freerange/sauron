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

  attr_reader :message_index, :mail_store

  def initialize(message_index = MessageRepository::ActiveRecordMessageIndex, mail_store = CacheBackedMailStore)
    @message_index = message_index
    @mail_store = mail_store
  end

  def highest_mail_uid(account)
    message_index.highest_uid(account)
  end

  def add_mail(mail)
    hash = Digest::SHA1.hexdigest(mail.message_id)
    mail_store.add mail
    record = message_index.add mail, hash
    Message.new(record, mail_store)
  end

  def mail_exists?(account, uid)
    message_index.mail_exists?(account, uid)
  end

  def find(message_hash)
    record = message_index.find_primary_message_index_record(message_hash)
    Message.new(record, mail_store)
  end

  def find_by_message_id(message_id)
    record = message_index.find_by_message_id(message_id)
    Message.new(record, mail_store) if record
  end

  def find_replies_to(message_id)
    records = message_index.find_replies_to(message_id)
    records.map { |r| Message.new(r, mail_store) }
  end

  def messages
    message_index.most_recent.map do |record|
      Message.new(message_index.find_primary_message_index_record(record.message_hash), mail_store)
    end
  end
end

