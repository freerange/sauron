require 'test_helper'

class GmailImapClient::AuthenticatedConnectionTest < ActiveSupport::TestCase
  test "should connect to the gmail imap server" do
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, true).returns(stub_everything)
    GmailImapClient::AuthenticatedConnection.new('email', 'password')
  end

  test "should login using the supplied email and password" do
    email, password = "email", "password"
    imap = stub("imap")
    imap.expects(:login).with(email, password)
    Net::IMAP.stubs(:new).returns(imap)
    GmailImapClient::AuthenticatedConnection.new(email, password)
  end
end

class GmailImapClientTest < ActiveSupport::TestCase
  test "should return a new client with connection created with supplied credentials" do
    client = stub('client')
    connection = stub('connection')
    GmailImapClient.connection_class.stubs(:new).with('email', 'password').returns(connection)
    GmailImapClient.stubs(:new).with(connection).returns(client)
    assert_equal client, GmailImapClient.connect('email', 'password')
  end

  test "selects [Gmail]/All Mail mailbox if it exists" do
    connection = stub('connection')
    connection.stubs(:list).with('', '%').returns([stub(name: 'Anything'), stub(name: '[Gmail]')])
    connection.expects(:examine).with('[Gmail]/All Mail')
    GmailImapClient.new(connection)
  end

  test "selects [Google Mail]/All Mail mailbox if there is no [Gmail] mailbox" do
    connection = stub('connection')
    connection.stubs(:list).with('', '%').returns([stub(name: 'Anything')])
    connection.expects(:examine).with('[Google Mail]/All Mail')
    GmailImapClient.new(connection)
  end

  test "searches for uids of messages in the INBOX" do
    connection = stub('imap-connection', examine: nil, list: [])
    connection.stubs(:uid_search).with('ALL').returns [1, 2, 3, 4]
    client = GmailImapClient.new(connection)
    assert_equal [1, 2, 3, 4], client.inbox_uids
  end

  test "fetches a single message from INBOX given its uid" do
    connection = stub('imap-connection', examine: nil, list: [])
    connection.stubs(:uid_fetch).with([1], 'BODY.PEEK[]').returns [
      stub(attr: {"BODY[]" => "raw-message-body-1"})
    ]
    client = GmailImapClient.new(connection)
    assert_equal 'raw-message-body-1', client.inbox_message(1)
  end

  test "fetches multiple messages from INBOX given their uids" do
    connection = stub('imap-connection', examine: nil, list: [])
    connection.stubs(:uid_fetch).with([1, 2], 'BODY.PEEK[]').returns [
      stub(attr: {"BODY[]" => "raw-message-body-1"}),
      stub(attr: {"BODY[]" => "raw-message-body-2"})
    ]
    client = GmailImapClient.new(connection)
    assert_equal ['raw-message-body-1', 'raw-message-body-2'], client.inbox_messages(1, 2)
  end
end