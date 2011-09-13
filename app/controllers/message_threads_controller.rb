class MessageThreadsController < ApplicationController
  def index
    @threads = MessageThread.all
  end

  def show
    @thread = MessageThread.find(params[:id])
  end
end