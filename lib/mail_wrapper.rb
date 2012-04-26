class MailWrapper
  delegate :date, :message_id, to: :@mail

  def initialize(raw_mail)
    @mail = ::Mail.new(raw_mail)
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