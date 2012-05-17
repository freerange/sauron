class PingsController < ActionController::Base
  def show
    MessageRepository.messages(1)
    ConversationRepository.conversations
    render text: "OK"
  end
end
