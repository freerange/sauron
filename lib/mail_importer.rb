class MailImporter
  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(message_repository, conversation_repository)
    highest_uid = message_repository.highest_mail_uid(mailbox.email)
    mailbox.uids(highest_uid).each do |uid|
      unless message_repository.mail_exists?(mailbox.email, uid)
        begin
          Rails.logger.info("Importing mail UID #{uid} for account #{mailbox.email}")
          mail = mailbox.mail(uid)
          message = message_repository.add_mail(mail)
          conversation_repository.add_message(message)
        rescue => e
          Rails.logger.error(e.inspect)
          Rails.logger.error(e.backtrace.join("\n"))
          raise "Failed to import mail with UID=#{uid.inspect} (#{e.inspect}). See log for details."
        end
      end
    end
  end
end