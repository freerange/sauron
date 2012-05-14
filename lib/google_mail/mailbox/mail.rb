module GoogleMail
  class Mailbox
    class Mail
      attr_reader :account, :uid, :raw, :raw_mail
      delegate :date, :message_id, :from, :subject, :delivered_to, to: :raw_mail

      def initialize(account, uid, raw)
        @account = account
        @uid = uid
        @raw = raw
        @raw_mail = RawMail.new(raw)
      end

      def ==(m)
        m.is_a?(self.class) && m.account == account && m.uid == uid && m.raw == raw
      end
    end
  end
end
