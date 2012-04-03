require 'mail'

class MessageRepository
  class Record < ActiveRecord::Base
    self.table_name = :messages

    class << self
      def most_recent
        all(order: "date DESC", limit: 2500)
      end

      def message_exists?(account_id, uid)
        exists?(account: account_id, uid: uid)
      end
    end
  end

  class Message
    attr_reader :record, :original
    delegate :subject, :date, :from, :to_param, to: :record

    def initialize(record, original = "")
      @record = record
      @original = original
    end

    def ==(message)
      message.is_a?(Message) &&
      message.record == record
    end
  end

  class LazyOriginalMessage
    def initialize(account, uid, store)
      @account = account
      @uid = uid
      @store = store
    end

    def to_s
      @message ||= @store.find(@account, @uid)
    end
  end

  class << self
    attr_writer :instance

    delegate :find, :add, :exists?, :messages, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :model

  def initialize(model = Record, store = CacheBackedMessageStore)
    @model = model
    @store = store
  end

  def add(account, uid, raw_message)
    mail = Mail.new(raw_message)
    @model.create! account: account, uid: uid, subject: mail.subject, date: mail.date, from: mail.from.first
    @store.add account, uid, raw_message
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