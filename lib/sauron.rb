module Sauron
  autoload :RawMessage, 'sauron/raw_message'

  def self.update
    threads = ::GmailAccount.all.map do |account|
      Thread.new do
        begin
          account.each_new_message do |raw_message|
            begin
              raw_message.import!
            rescue => e
              filename = "tmp/message_failures/#{account.id}-message-#{raw_message.uid}"
              puts "Failed to import message #{raw_message.uid}"
              puts e
              begin
                File.open(filename, "w") { |f| f.write raw_message.raw_string }
              rescue => e
                puts "Couldn't even save file!"
                puts e
                File.open(filename, "w") { |f| f.write e.to_s }
              end
            end
          end
        rescue Net::IMAP::NoResponseError
          puts "Couldn't log in for #{account.email}; skipping"
        end
      end
    end
    threads.each { |t| t.join }
    puts "Done import."
  end
end