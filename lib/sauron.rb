module Sauron
  autoload :GmailAccount, "sauron/gmail_account"
  autoload :Message, "sauron/message"
  autoload :MessageStore, "sauron/message_store"

  def self.update
    message_store = Sauron::MessageStore.new

    Sauron::GmailAccount.all.each do |account|
      account.each_new_message do |message, uid|
        message_store.insert message, uid
      end
    end
  end
end