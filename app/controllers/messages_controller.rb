require 'message_repository'

class MessagesController < ApplicationController
  def index
    @messages = MessageRepository.messages
  end

  def search
    if params[:q].present?
      @messages = MessageRepository.search(params[:q])
    else
      @messages = []
    end
    render :index
  end

  def show
    unless @message = MessageRepository.find(params[:id])
      render_not_found
    end
  end
end