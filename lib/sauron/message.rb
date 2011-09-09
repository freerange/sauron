require 'mail'
require 'time'

module Sauron
  class Message
    attr_reader :raw_message

    def initialize(raw_message_as_string)
      @raw_message = raw_message_as_string
      @mail = Mail.new(@raw_message)
    end

    def headers
      mail_header_to_hash(@mail.header)
    end

    def parts
      @mail.parts.map do |part|
        mail_part_to_hash(part)
      end
    end

    def body
      reencoded_mail_body(@mail.body)
    end

    def message_id
      @mail.message_id
    end

    def to_hash
      h = {
        message_id: message_id,
        date: Time.parse(headers["Date"]),
        to: headers["To"],
        from: headers["From"],
        subject: headers["Subject"],
        headers: headers,
        multipart: @mail.multipart?
      }
      if @mail.multipart?
        h[:parts] = parts
      else
        h[:body] = body
      end
      h
    end

    private

    def mail_header_to_hash(header)
      header.fields.inject({}) { |h, f| h[f.name.to_s] = f.value.to_s; h }
    end

    def reencoded_mail_body(body)
      body_string = body.decoded
      body_string.force_encoding("ISO-8859-1")
      raise "guess ISO-8859-1 but it wasn't valid" unless body_string.valid_encoding?
      body_string.encode("UTF-8")
    end

    def mail_part_to_hash(part)
      hash = { headers: mail_header_to_hash(part.header) }
      if part.attachment? || MIME::Type.new(part.content_type).binary?
        hash[:body] = part.body.encoded
      else
        part_string = part.body.decoded
        charset = encoding_for(part)
        part_string.force_encoding(charset)
        raise "guess #{charset} but it wasn't valid" unless part_string.valid_encoding?
        hash[:body] = part_string.encode("UTF-8")
      end
      hash
    end

    def encoding_for(part)
      encoding = part.header.charset || part.body.charset || "ISO-8859-1"
      encoding = "UTF-8" if encoding == "utf8"
      encoding
    end
  end
end