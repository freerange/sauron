class MessageImporter
  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(repository)
    highest_uid = repository.highest_uid(mailbox.email)
    mailbox.uids(highest_uid).each do |uid|
      unless repository.exists?(mailbox.email, uid)
        begin
          repository.add mailbox.email, uid, mailbox.raw_message(uid)
        rescue
          raise "Failed to import message with UID=#{uid.inspect}"
        end
      end
    end
  end
end