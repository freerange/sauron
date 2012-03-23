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

    test "searches for uids of messages in the INBOX" do
      connection = stub('imap-connection', examine: nil, list: [])
      connection.stubs(:uid_search).with('ALL').returns [1, 2, 3, 4]
      mailbox = Mailbox.new(connection)
      assert_equal [1, 2, 3, 4], mailbox.uids
    end

    test "fetches a single message from INBOX given its uid" do
      connection = stub('imap-connection', examine: nil, list: [])
      connection.stubs(:uid_fetch).with([1], 'BODY.PEEK[]').returns [
        stub(attr: {"BODY[]" => "raw-message-body-1"})
      ]
      mailbox = Mailbox.new(connection)
      assert_equal 'raw-message-body-1', mailbox.message(1)
    end

    test "fetches multiple messages from INBOX given their uids" do
      connection = stub('imap-connection', examine: nil, list: [])
      connection.stubs(:uid_fetch).with([1, 2], 'BODY.PEEK[]').returns [
        stub(attr: {"BODY[]" => "raw-message-body-1"}),
        stub(attr: {"BODY[]" => "raw-message-body-2"})
      ]
      mailbox = Mailbox.new(connection)
      assert_equal ['raw-message-body-1', 'raw-message-body-2'], mailbox.messages(1, 2)
    end
  end
end