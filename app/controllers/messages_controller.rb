require 'gmail'

class MessagesController < ApplicationController
  def index
    @messages = Gmail.messages(Gmail.email, Gmail.password)
  end
end