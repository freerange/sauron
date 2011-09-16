require "base64"

module Sauron
  autoload :RawMessage, 'sauron/raw_message'

  MESSAGE_DIRECTORY = "tmp/messages"

  def self.update
    download
    import
  end

  def self.download
    FileUtils.mkdir_p(MESSAGE_DIRECTORY)
    threads = ::GmailAccount.all.map do |account|
      dir = account_message_directory(account)
      FileUtils.mkdir_p(dir)
      Thread.new do
        begin
          account.each_new_message do |message_as_string, uid|
            File.open(File.join(dir, uid.to_s + ".new"), "w") do |f|
              f.write Base64.encode64(message_as_string)
            end
          end
        rescue Net::IMAP::NoResponseError
          puts "Couldn't log in for #{account.email}; skipping"
        end
      end
    end
    threads.each { |t| t.join }
    puts "Done download."
  end

  def self.import
    ::GmailAccount.all.each do |account|
      with_new_messages_for_account(account) do |message_string, uid|
        begin
          raw_message = Sauron::RawMessage.new(message_string, uid)
          raw_message.import!
        rescue => e1
          filename = "tmp/message_failures/#{account.id}-message-#{raw_message.uid}"
          puts "Failed to import message #{raw_message.uid}"
          puts e1
          puts e1.backtrace
          begin
            File.open(filename, "w") { |f| f.write raw_message.raw_string }
          rescue => e2
           puts "Couldn't even save file!"
           puts e2
           puts e2.backtrace
           File.open(filename, "w") { |f| f.write e2.to_s }
          end
        end
      end
    end
    puts "Done import."
  end

  def self.account_message_directory(account)
    File.join(MESSAGE_DIRECTORY, account.email.split("@")[0])
  end

  def self.with_new_messages_for_account(account)
    directory = account_message_directory(account)
    unimported_files = Dir[File.join(directory, "/*.new")].sort_by { |f| File.basename(f, ".new").to_i }
    unimported_files.each do |filename|
      yield Base64.decode64(File.read(filename)), File.basename(filename, ".new").to_i
      FileUtils.mv(filename, File.join(directory, File.basename(filename, ".new")))
    end
  end
end