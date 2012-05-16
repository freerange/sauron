require 'mail'

class ParsedMail
  attr_reader :mail, :raw_text
  delegate :date, :to, :cc, to: :mail

  def initialize(raw_text)
    @mail = Mail.new(raw_text)
    @raw_text = raw_text
  end

  def message_id
    mail.message_id || raw_text.match(/^Message-Id\:(.*)$/i)[1].strip
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

  def body
    if mail.multipart?
      text_part_bodies(mail).join
    else
      force_to_utf8(mail)
    end
  end

  def delivered_to
    # The mail gem seems reluctant to return a real string, hence the double #to_s
    [@mail["Delivered-To"]].flatten.map { |x| x.to_s.to_s }
  end

  def ==(instance)
    instance.is_a?(self.class) && instance.raw_text == self.raw_text
  end

  private

  def text_part_bodies(part)
    part.parts.inject([]) do |bodies, part|
      if part.multipart?
        bodies << text_part_bodies(part)
      elsif part.content_type =~ /text\/plain/
        bodies << force_to_utf8(part)
      end
      bodies.flatten
    end
  end

  def force_to_utf8(part)
    part.decoded
  rescue
    part.body.to_s.encode('UTF-8', invalid: :replace, undef: :replace)
  end
end