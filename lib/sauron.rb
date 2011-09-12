module Sauron
  autoload :RawMessage, 'sauron/raw_message'

  def self.update
    Sauron::GmailAccount.all.each do |account|
      account.each_new_message do |raw_message|
        Message.create!(raw_message.attributes)
      end
    end
  end
end