class ConversationsController < ApplicationController
  def index
    @conversations = ConversationRepository.conversations
  end
end
