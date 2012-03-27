require 'mail'

class MessageRepository
  class << self
    attr_writer :instance

    delegate :messages, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :message_store

  def initialize(store = FileBasedMessageStore.new)
    @message_store = store
  end

  def include?(key)
    message_store.include?(key)
  end

  def add(key, message)
    message_store[key] = message
  end

  def messages
    message_store.values.map do |message|
      Mail.new message
    end
  end
end