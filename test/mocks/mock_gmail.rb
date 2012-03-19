require 'net/imap'

module MockGmail
  class Server
    class Account
      def add_message(mailbox, message)
        mailboxes[mailbox] << message.object_id
        messages[message.object_id] = message.to_s
      end

      def mailboxes
        @mailboxes ||= Hash.new do |hash, key|
          hash[key] = []
        end
      end

      def messages
        @messages ||= {}
      end
    end

    def accounts
      @accounts ||= Hash.new do |hash, key|
        hash[key] = Account.new
      end
    end
  end

  mattr_accessor :server
  self.server ||= Server.new

  class Connection
    def initialize(email, password)
      @email = email
      @password = password
    end

    def select(mailbox)
      @mailbox = mailbox
    end

    def uid_search(name)
      raise 'Mock only supports ALL' unless name == 'ALL'
      account.mailboxes[@mailbox]
    end

    def uid_fetch(uid, scope)
      raise 'Mock only supports BODY.PEEK[]' unless scope == 'BODY.PEEK[]'
      [Net::IMAP::FetchData.new(1, 'UID' => uid, 'BODY[]' => account.messages[uid])]
    end

    def server
      MockGmail.server
    end

    def account
      server.accounts[@email]
    end
  end
end