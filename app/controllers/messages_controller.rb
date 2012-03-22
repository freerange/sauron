class MessagesController < ApplicationController
  def index
    @messages = MessageRepository.messages
  end
end