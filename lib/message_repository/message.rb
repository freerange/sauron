class MessageRepository::Message
  attr_reader :record, :original
  delegate :subject, :date, :from, :to_param, to: :record

  def initialize(record, original = "")
    @record = record
    @original = original
  end

  def body
    mail = Mail.new(@original)
    if mail.multipart?
      text_part_bodies(mail).join
    else
      mail.decoded
    end
  end

  def ==(message)
    message.is_a?(MessageRepository::Message) &&
    message.record == record
  end

  private

  def text_part_bodies(part)
    part.parts.inject([]) do |bodies, part|
      if part.multipart?
        bodies << text_part_bodies(part)
      elsif part.content_type =~ /text\/plain/
        bodies << part.decoded
      end
      bodies.flatten
    end
  end
end
