module GoogleMail
  class Mailbox
    class Mail
      attr_reader :account, :uid, :raw, :parsed_mail
      delegate :date, :message_id, :from, :to, :cc, :subject, :body, :delivered_to, to: :parsed_mail

      def initialize(account, uid, raw)
        @account = account
        @uid = uid
        @raw = raw
        @parsed_mail = ParsedMail.new(raw)
      end

      def ==(m)
        m.is_a?(self.class) && m.account == account && m.uid == uid && m.raw == raw
      end
    end
  end
end
