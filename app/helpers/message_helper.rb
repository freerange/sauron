module MessageHelper
  def message_class(message, username)
    message.sent_or_received_by?(username) ? "message sent-or-received" : "message neither-sent-nor-received"
  end
end
