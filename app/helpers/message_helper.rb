module MessageHelper
  def message_class(message, username)
    ["message", message_reply_class(message), message_received_class(message, username)].compact.join(" ")
  end

  def message_received_class(message, username)
    message.received_by?(username) ? "received" : "not-received"
  end

  def message_reply_class(message)
    conversation = Conversation.new(message, MessageRepository.new)
    conversation.has_reply_from_us? ? "responded" : "needs_response"
  end
end
