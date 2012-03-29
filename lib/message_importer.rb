class MessageImporter
  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(repository)
    mailbox.uids.each do |uid|
      unless repository.exists?(mailbox.email, uid)
        repository.add mailbox.email, uid, mailbox.message(uid)
      end
    end
  end
end