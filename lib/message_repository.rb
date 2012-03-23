require 'mail'

class MessageRepository
  class KeyGenerator
    def key_for(id)
      Digest::MD5.hexdigest(id.to_s)
    end
  end

  class << self
    attr_writer :instance

    delegate :messages, to: :instance

    def instance
      @instance ||= new(FileBasedMessageStore.new("data/#{Rails.env}"))
    end
  end

  delegate :key_for, to: :@key_generator
  attr_reader :message_store

  def initialize(store, key_generator = KeyGenerator.new)
    @message_store = store
    @key_generator = key_generator
  end

  def store(id, message)
    message_store[key_for(id)] = message
  end

  def messages
    message_store.values.map do |message|
      Mail.new message
    end
  end
end