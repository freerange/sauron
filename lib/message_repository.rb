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

  def initialize(message_index = MessageRepository::ElasticSearchMessageIndex.new, mail_store = CacheBackedMailStore)
    @message_index = message_index
    @mail_store = mail_store
  end

  def highest_mail_uid(account)
    message_index.highest_uid(account)
  end

  def add_mail(mail)
    message_index.add mail
    mail_store.add mail
  end

  def mail_exists?(account, uid)
    message_index.mail_exists?(account, uid)
  end

  def find(message_hash)
    record = message_index.find_by_message_hash(message_hash)
    Message.new(record, mail_store)
  end

  def messages
    message_index.most_recent.map do |record|
      Message.new(record, mail_store)
    end
  end
end

