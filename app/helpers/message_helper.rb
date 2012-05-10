module MessageHelper
  def message_class(message, username)
    message.received_by?(username) || message.sent_by?(username) ? "message received" : "message not-received"
  end
end
