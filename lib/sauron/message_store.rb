require "mongo"

module Sauron
  class MessageStore
    def initialize
      @connection = Mongo::Connection.new
      @db = @connection['sauron']
      @collection = @db['messages']
      @collection.ensure_index([[:message_id, Mongo::ASCENDING]], {unique: true})
    end

    def insert(message, uid)
      @collection.insert(message.to_hash)
    rescue => e
      require "fileutils"
      dir = "tmp/message_failures"
      FileUtils.mkdir_p(dir)
      filename = File.join(dir, "message-#{uid}.yml")
      puts "Failed to insert message; writing to #{filename}"
      File.open(filename, "w") { |f| f.puts e.to_s; f.puts message.raw_message }
    end
  end
end