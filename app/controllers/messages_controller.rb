require 'message_repository'

class MessagesController < ApplicationController
  def index
    @messages = MessageRepository.messages
  end

  def show
    @message = MessageRepository.find(params[:id])
  end
end