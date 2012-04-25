class MessageRepository::MailWrapper
  delegate :date, to: :@mail

  def initialize(raw_message)
    @mail = ::Mail.new(raw_message)
  end

  def from
    @mail.from ? @mail.from.first : nil
  end

  def subject
    if @mail.subject
      if @mail.subject.encoding == Encoding.find("ASCII-8BIT")
        @mail.subject.force_encoding("Windows-1252").encode("UTF-8")
      else
        @mail.subject
      end
    end
  end
end