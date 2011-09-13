module Sauron
  autoload :RawMessage, 'sauron/raw_message'

  def self.update
    ::GmailAccount.all.each do |account|
      account.each_new_message do |raw_message|
        begin
          raw_message.import!
        rescue => e
          puts "Failed to import message #{raw_message.uid}"
          File.open("tmp/message_failures/message-#{raw_message.uid}", "w") { |f| f.write raw_message.raw_string }
        end
      end
    end
  end
end