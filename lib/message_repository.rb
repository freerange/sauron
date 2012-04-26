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

  attr_reader :model

  def initialize(model = Record, store = CacheBackedMessageStore)
    @model = model
    @store = store
  end

  def highest_uid(account)
    @model.highest_uid(account)
  end

  def add(message)
    @model.add message
    @store.add message
  end

  def exists?(account, uid)
    @model.message_exists?(account, uid)
  end

  def find(id)
    record = @model.where(id: id).first
    record && Message.new(record, LazyOriginalMessage.new(record.account, record.uid, @store))
  end

  def messages
    @model.most_recent.map do |record|
      Message.new record, LazyOriginalMessage.new(record.account, record.uid, @store)
    end
  end
end