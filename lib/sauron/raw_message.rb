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

    def attributes
      h = {
        message_id: message_id,
        uid: @uid,
        date: Time.parse(headers["Date"]),
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
      return if Message.where(message_id: message_id).first
      puts "creating #{@uid} / #{message_id}"
      message = Message.create!(attributes)

      message.from = contact_from(headers["From"])
      message.to = contacts_from(headers["To"])
      message.cc = contacts_from(headers["Cc"])

      [message.from, message.to, message.cc].flatten.each do |contact|
        contact.messages << message unless contact.message_ids.include?(message.id)
      end

      in_reply_to = if headers["In-Reply-To"]
        headers["In-Reply-To"].gsub(/^</, '').gsub(/>$/, '')
      else
        nil
      end
      message_replied_to = Message.where(message_id: in_reply_to).first

      if message_replied_to
        message.in_reply_to = message_replied_to
        thread = message_replied_to.message_thread
      else
        thread = MessageThread.create!
      end

      message.save
      thread.messages << message
      thread.save
      message
    end

    private

    def contact_from(header)
      a = Mail::Address.new(header)
      Contact.where(email: a.address).first || Contact.create(name: a.display_name, email: a.address)
    end

    def contacts_from(header)
      addresses = Mail::AddressList.new(header).addresses
      addresses.map do |a|
        Contact.where(email: a.address).first || Contact.create(name: a.display_name, email: a.address)
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