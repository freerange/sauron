class MessageImporter
  class ImportError < RuntimeError
    attr_reader :uid

    def initialize(uid)
      @uid = uid
    end

    def message
      "Failed to import message with UID=#{@uid.inspect}"
    end
  end

  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(repository)
    mailbox.each_uid_and_message do |uid, message|
      unless repository.exists?(mailbox.email, uid)
        begin
          repository.add mailbox.email, uid, message.force
        rescue => e
          raise ImportError.new(uid)
        end
      end
    end
  end
end