module GoogleMail
  class Mailbox
    class Mail
      attr_reader :account, :uid, :raw
      delegate :date, :in_reply_to, to: :@mail

      def initialize(account, uid, raw)
        @account = account
        @uid = uid
        @raw = raw
        @mail = ::Mail.new(raw)
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

      def delivered_to
        @mail["Delivered-To"].to_s
      end

      def message_id
        @mail.message_id || raw.match(/^Message-Id\:(.*)$/i)[1].strip
      end

      def ==(mail)
        mail.is_a?(self.class) && mail.account == account && mail.uid == uid && mail.raw == raw
      end
    end
  end
end
