class ConversationsController < ApplicationController
  def index
    @conversations = ConversationRepository.conversations
  end

  def show
    @conversation = ConversationRepository.find(params[:id])
  end
end
