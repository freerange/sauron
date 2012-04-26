class MessageRepository::Message
  attr_reader :index_record
  delegate :subject, :date, :from, :to_param, to: :index_record

  def initialize(index_record, store)
    @index_record = index_record
    @store = store
  end

  def body
    parsed_mail = Mail.new(raw_message)
    if parsed_mail.multipart?
      text_part_bodies(parsed_mail).join
    else
      parsed_mail.decoded
    end
  end

  def ==(message)
    message.is_a?(MessageRepository::Message) &&
    message.index_record == index_record
  end

  private

  def raw_message
    @raw_message ||= @store.find(index_record.account, index_record.uid)
  end

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
