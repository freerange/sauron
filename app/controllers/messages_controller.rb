class MessagesController < ApplicationController
  def index
    @messages = GmailAccount.messages
  end
end