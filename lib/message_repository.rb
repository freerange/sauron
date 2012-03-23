require 'mail'

class MessageRepository
  class << self
    attr_writer :instance

    delegate :messages, to: :instance

    def instance
      @instance ||= new(FileBasedMessageStore.new("data/#{Rails.env}"))
    end
  end

  attr_reader :message_store

  def initialize(store)
    @message_store = store
  end

  def include?(id)
    message_store.include?(id)
  end

  def store(id, message)
    message_store[id] = message
  end

  def messages
    message_store.values.map do |message|
      Mail.new message
    end
  end
end