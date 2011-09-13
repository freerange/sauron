module Sauron
  class RawMessage
    attr_reader :raw_string, :uid

    def initialize(raw_message_as_string, uid)
      @raw_string = raw_message_as_string
      @mail = Mail.new(@raw_string)
      @uid = uid
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

    def in_reply_to
      raw_in_reply_to = headers["In-Reply-To"]
      if raw_in_reply_to
        raw_in_reply_to.gsub(/^</, '').gsub(/>$/, '')
      else
        nil
      end
    end

    def contacts
      ["To", "From", "Cc"].inject([]) do |a, header|
        begin
          a + Mail::AddressList.new(headers[header]).addresses
        rescue
          a
        end
      end.map { |email| [email.display_name, email.address] }
    end

    def attributes
      h = {
        message_id: message_id,
        in_reply_to: in_reply_to,
        uid: @uid,
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

    def import!
      message = Message.create!(attributes)
      contacts.each do |name, email|
        contact = Contact.find_or_create_by(name: name, email: email)
        contact.messages << message
      end

      message_replied_to = Message.where(message_id: in_reply_to).first
      thread = message_replied_to ? message_replied_to.message_thread : MessageThread.create!
      thread.messages << message
      thread.save
      message
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