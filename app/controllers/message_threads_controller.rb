class MessageThreadsController < ApplicationController
  def index
    @threads = MessageThread.page(params[:page])
  end

  def show
    @thread = MessageThread.find(params[:id])
  end
end