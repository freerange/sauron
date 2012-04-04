class MessageImporter
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
          raise "Failed to import message with UID=#{uid.inspect}"
        end
      end
    end
  end
end