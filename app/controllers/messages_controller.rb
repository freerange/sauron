require 'message_repository'

class MessagesController < ApplicationController
  def index
    @messages = MessageRepository.messages
  end

  def show
    unless @message = MessageRepository.find(params[:id])
      render nothing: true, status: :not_found
    end
  end
end