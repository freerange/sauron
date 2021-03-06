class MessageRepository::Message
  attr_reader :index_record
  delegate :subject, :date, :from, :to, :message_id, :message_hash, to: :index_record
  delegate :body, :in_reply_to, to: :parsed_mail

  def initialize(index_record, store)
    @index_record = index_record
    @store = store
  end

  def recipients
    index_record.recipients.reject(&:blank?)
  end

  def received_by?(email)
    recipients.include?(email)
  end

  def sent_by?(email)
    email == from
  end

  def sent_or_received_by?(email)
    received_by?(email) || sent_by?(email)
  end

  def ==(message)
    message.is_a?(MessageRepository::Message) &&
    message.index_record == index_record
  end

  def raw_mail
    @raw_mail ||= @store.find(*index_record.mail_identifier)
  end

  def displayable_raw_mail
    raw_mail.force_encoding('UTF-8')
  end

  def to_param
    message_hash
  end

  def parsed_mail
    @parsed_mail ||= ParsedMail.new(raw_mail)
  end
end
