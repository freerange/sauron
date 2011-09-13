module Sauron
  autoload :RawMessage, 'sauron/raw_message'

  def self.update
    ::GmailAccount.all.each do |account|
      begin
        account.each_new_message do |raw_message|
          begin
            raw_message.import!
          rescue => e
            puts "Failed to import message #{raw_message.uid}"
            File.open("tmp/message_failures/message-#{raw_message.uid}", "w") { |f| f.write raw_message.raw_string }
          end
        end
      rescue Net::IMAP::NoResponseError
        puts "Couldn't log in for #{account.email}; skipping"
      end
    end
  end
end