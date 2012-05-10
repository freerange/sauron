require 'net/imap'

module FakeGmail
  class Server
    class Account
      def initialize
        @uid = 0
        mailboxes['[Gmail]']
      end

      def next_uid
        @uid += 1
      end

      def add_mail(mail)
        uid = next_uid
        mailboxes['[Gmail]/All Mail'] << uid
        uids_vs_mails[uid] = mail.to_s
        uid
      end

      def add_draft_mail(mail)
        uid = add_mail(mail)
        draft_uids << uid
        uid
      end

      def mailboxes
        @mailboxes ||= Hash.new do |hash, key|
          hash[key] = []
        end
      end

      def uids_vs_mails
        @mails ||= {}
      end

      def draft_uids
        @draft_uids ||= []
      end
    end

    def accounts
      @accounts ||= Hash.new do |hash, key|
        hash[key] = Account.new
      end
    end

    def reset!
      @accounts = nil
    end
  end

  mattr_accessor :server
  self.server ||= Server.new

  class Connection
    attr_reader :email

    def initialize(email, password)
      @email = email
      @password = password
    end

    def examine(mailbox)
      @mailbox = mailbox
    end

    def list(box, search)
      unless box == '' && search == '%'
        raise 'Mock only supports list with no chosen box and a % search'
      end
      account.mailboxes.keys.map { |name| Net::IMAP::MailboxList.new([], '/', name) }
    end

    def uid_search(option)
      case option
        when /ALL X-GM-LABELS Draft/
          account.mailboxes[@mailbox].select { |uid| account.draft_uids.include?(uid) }
        when /ALL/
          account.mailboxes[@mailbox]
        when /UID (\d+)\:\* X-GM-LABELS Draft/
          account.mailboxes[@mailbox].select { |uid| uid >= $1.to_i && account.draft_uids.include?(uid) }
        when /UID (\d+)\:\*/
          account.mailboxes[@mailbox].select { |uid| uid >= $1.to_i }
        else
          raise "Mock does not support: #{option}"
      end
    end

    def uid_fetch(uids, scope)
      uids = [*uids]
      raise 'Mock only supports BODY.PEEK[]' unless scope == 'BODY.PEEK[]'
      uids.map do |uid|
        Net::IMAP::FetchData.new(1, 'UID' => uid, 'BODY[]' => account.uids_vs_mails[uid])
      end
    end

    def server
      FakeGmail.server
    end

    def account
      server.accounts[@email]
    end
  end
end
