class MessageRepository::Message
  attr_reader :index_records
  delegate :subject, :date, :from, :message_id, :message_hash, to: :index_record

  def initialize(index_records, store)
    @index_records = index_records
    @store = store
  end

  def recipients
    parsed_mails.map { |m| m["Delivered-To"] }.compact.map(&:to_s)
  end

  def received_by?(email)
    recipients.include?(email)
  end

  def body
    if parsed_mails.first.multipart?
      text_part_bodies(parsed_mails.first).join
    else
      parsed_mails.first.decoded
    end
  end

  def ==(message)
    message.is_a?(MessageRepository::Message) &&
    message.index_records == index_records
  end

  def raw_messages
    @raw_messages ||= @index_records.map do |record|
      @store.find(record.account, record.uid)
    end
  end

  def to_param
    message_hash
  end

  def index_record
    index_records.first
  end

  def parsed_mails
    @parsed_mails ||= raw_messages.map { |rm| Mail.new(rm) }
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
