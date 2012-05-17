require 'message_repository'

class MessagesController < ApplicationController
  def index
    @messages = MessageRepository.messages(500)
  end

  def search
    if params[:q].present?
      @messages = MessageRepository.search(params[:q])
    else
      redirect_to action: 'index'
    end
  end

  def show
    unless @message = MessageRepository.find(params[:id])
      render_not_found
    end
  end
end