class MessageRepository
  class KeyGenerator
    def key_for(message)
      Digest::MD5.hexdigest(message)
    end
  end

  class << self
    def messages

    end
  end

  delegate :key_for, to: :@key_generator
  attr_reader :message_store

  def initialize(store, key_generator = KeyGenerator.new)
    @message_store = store
    @key_generator = key_generator
  end

  def store(message)
    message_store[key_for(message)] = message
  end

  def messages
    message_store.values.map do |message|
      Mail.new message
    end
  end
end