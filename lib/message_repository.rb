# encoding: utf-8
require 'mail'

class MessageRepository
  class << self
    attr_writer :instance

    delegate :highest_uid, :find, :add, :exists?, :messages, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :index

  def initialize(index = ActiveRecordMessageIndex, store = CacheBackedMessageStore)
    @index = index
    @store = store
  end

  def highest_uid(account)
    @index.highest_uid(account)
  end

  def add(message)
    @index.add message
    @store.add message
  end

  def exists?(account, uid)
    @index.message_exists?(account, uid)
  end

  def find(id)
    record = @index.where(id: id).first
    record && Message.new(record, LazyOriginalMessage.new(record.account, record.uid, @store))
  end

  def messages
    @index.most_recent.map do |record|
      Message.new record, LazyOriginalMessage.new(record.account, record.uid, @store)
    end
  end
end