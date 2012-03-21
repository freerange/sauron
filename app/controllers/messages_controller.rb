class MessagesController < ApplicationController
  def index
    @messages = GmailAccount.messages(GmailAccount.email, GmailAccount.password)
  end
end