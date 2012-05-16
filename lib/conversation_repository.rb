class ConversationRepository

  class << self
    attr_writer :instance

    delegate :add_message, :conversations, to: :instance

    def instance
      @instance ||= new(ConversationRepository::ConversationIndex.new)
    end
  end

  def initialize(index)
    @index = index
  end

  def add_message(message)
    @index.add(message)
  end

  def conversations
    @index.most_recent
  end
end
