require 'mail'

class MessageRepository
  class Message
    attr_reader :mail
    delegate :subject, :date, :from, to: :mail

    def initialize(body)
      @mail = Mail.new(body)
    end

    def ==(message)
      message.is_a?(Message) && message.mail == mail
    end
  end

  class << self
    attr_writer :instance

    delegate :add, :exists?, :messages, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :message_store

  def initialize(store = FileBasedMessageStore.new)
    @message_store = store
  end

  def add(key, message)
    message_store[key] = message
  end

  def exists?(key)
    message_store.include?(key)
  end

  def messages
    message_store.values.map do |message|
      Message.new message
    end
  end
end