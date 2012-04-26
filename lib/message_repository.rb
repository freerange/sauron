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
    mail_index.add mail
    mail_store.add mail
  end

  def mail_exists?(account, uid)
    mail_index.mail_exists?(account, uid)
  end

  def find(mail_id)
    record = mail_index.find_first(mail_id)
    record && Message.new(record, MailRepository::LazyOriginalMail.new(record.account, record.uid, mail_store))
  end

  def messages
    mail_index.most_recent.map do |record|
      Message.new record, MailRepository::LazyOriginalMail.new(record.account, record.uid, mail_store)
    end
  end
end