class MessageImporter
  class ImportError < StandardError
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
    mailbox.uids.each do |uid|
      unless repository.exists?(mailbox.email, uid)
        begin
          repository.add mailbox.email, uid, mailbox.message(uid)
        rescue
          raise ImportError.new(uid)
        end
      end
    end
  end
end