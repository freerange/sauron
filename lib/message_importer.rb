class MessageImporter
  attr_reader :mailbox

  def initialize(mailbox)
    @mailbox = mailbox
  end

  def import_into(repository)
    mailbox.uids.each do |uid|
      unless repository.include?(uid)
        repository.add uid, mailbox.message(uid)
      end
    end
  end
end