require 'test_helper'

module GoogleMail
  class Mailbox::AuthenticatedConnectionTest < ActiveSupport::TestCase
    test "should connect to the gmail imap server" do
      Net::IMAP.expects(:new).with('imap.gmail.com', 993, true).returns(stub_everything)
      Mailbox::AuthenticatedConnection.new('email', 'password')
    end

    test "should login using the supplied email and password" do
      email, password = "email", "password"
      imap = stub("imap")
      imap.expects(:login).with(email, password)
      Net::IMAP.stubs(:new).returns(imap)
      Mailbox::AuthenticatedConnection.new(email, password)
    end

    test "gives access to the email address the account represents" do
      email, password = "email", "password"
      imap = stub("imap", login: nil)
      Net::IMAP.stubs(:new).returns(imap)
      assert_equal 'email', Mailbox::AuthenticatedConnection.new(email, password).email
    end
  end

  class Mailbox::CachedConnectionTest < ActiveSupport::TestCase
    test "instantiates an AuthenticatedConnection to make imap requests through" do
      cache = stub('cache')
      Mailbox::AuthenticatedConnection.expects(:new).with('email', 'password')
      Mailbox::CachedConnection.new('email', 'password', cache)
    end

    test "delegates imap requests through its connection" do
      cache = stub('cache')
      connection = stub('connection')
      Mailbox::AuthenticatedConnection.stubs(:new).returns(connection)
      cached_connection = Mailbox::CachedConnection.new('email', 'password', cache)
      connection.expects(:uid_search).with('ALL')
      cached_connection.uid_search 'ALL'
    end

    test "uses cache to avoid repeated calls to uid_fetch" do
      cache = ActiveSupport::Cache::MemoryStore.new
      connection = stub('connection', email: 'tom@example.com')
      Mailbox::AuthenticatedConnection.stubs(:new).returns(connection)
      cached_connection = Mailbox::CachedConnection.new('email', 'password', cache)
      connection.stubs(:uid_fetch).with([1, 2, 3], 'ALL').returns(:result)
      assert_equal :result, cached_connection.uid_fetch([1, 2, 3], 'ALL')
      connection.stubs(:uid_fetch).never
      assert_equal :result, cached_connection.uid_fetch([1, 2, 3], 'ALL')
    end
  end

  class MailboxTest < ActiveSupport::TestCase
    test "should return a new mailbox with connection created with supplied credentials" do
      mailbox = stub('mailbox')
      connection = stub('connection')
      Mailbox.connection_class.stubs(:new).with('email', 'password').returns(connection)
      Mailbox.stubs(:new).with(connection).returns(mailbox)
      assert_equal mailbox, Mailbox.connect('email', 'password')
    end

    test "selects [Gmail]/All Mail mailbox if it exists" do
      connection = stub('connection')
      connection.stubs(:list).with('', '%').returns([stub(name: 'Anything'), stub(name: '[Gmail]')])
      connection.expects(:examine).with('[Gmail]/All Mail')
      Mailbox.new(connection)
    end

    test "selects [Google Mail]/All Mail mailbox if there is no [Gmail] mailbox" do
      connection = stub('connection')
      connection.stubs(:list).with('', '%').returns([stub(name: 'Anything')])
      connection.expects(:examine).with('[Google Mail]/All Mail')
      Mailbox.new(connection)
    end

    test "returns uids of all messages in the mailbox" do
      connection = stub('imap-connection', examine: nil, list: [])
      connection.stubs(:uid_search).with('ALL').returns [1, 2, 3, 4]
      mailbox = Mailbox.new(connection)
      assert_equal [1, 2, 3, 4], mailbox.uids
    end

    test "returns a single message given its uid" do
      connection = stub('imap-connection', examine: nil, list: [])
      connection.stubs(:uid_fetch).with(1, 'BODY.PEEK[]').returns [
        stub(attr: {"BODY[]" => "raw-message-body-1"})
      ]
      mailbox = Mailbox.new(connection)
      assert_equal 'raw-message-body-1', mailbox.message(1)
    end
  end
end