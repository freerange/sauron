class MailImporter
  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(repository)
    highest_uid = repository.highest_mail_uid(mailbox.email)
    mailbox.uids(highest_uid).each do |uid|
      unless repository.mail_exists?(mailbox.email, uid)
        begin
          Rails.logger.info("Importing mail UID #{uid} for account #{mailbox.email}")
          repository.add_mail mailbox.mail(uid)
        rescue => e
          Rails.logger.error(e.inspect)
          raise "Failed to import mail with UID=#{uid.inspect} (#{e.message})"
        end
      end
    end
  end
end