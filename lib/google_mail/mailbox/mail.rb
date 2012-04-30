module GoogleMail
  class Mailbox
    class Mail
      attr_reader :account, :uid, :raw, :wrapper
      delegate :from, :subject, :date, :message_id, to: :wrapper

      def initialize(account, uid, raw)
        @account = account
        @uid = uid
        @raw = raw
        @wrapper = MailWrapper.new(raw)
      end

      def ==(mail)
        mail.is_a?(self.class) && mail.account == account && mail.uid == uid && mail.raw == raw
      end
    end
  end
end
