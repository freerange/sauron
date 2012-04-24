class MessageImporter
  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(repository)
    mailbox.uids.each do |uid|
      unless repository.exists?(mailbox.email, uid)
        begin
          Rails.logger.info("Importing message UID #{uid} for account #{mailbox.email}")
          repository.add mailbox.email, uid, mailbox.raw_message(uid)
        rescue
          raise "Failed to import message with UID=#{uid.inspect}"
        end
      end
    end
  end
end