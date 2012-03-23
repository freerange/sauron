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

  test "selects INBOX mailbox during initialization" do
    connection = stub('connection')
    connection.expects(:examine).with('INBOX')
    GmailImapClient.new(connection)
  end

  test "searches for uids of messages in the INBOX" do
    connection = stub('imap-connection', examine: nil)
    connection.stubs(:uid_search).with('ALL').returns [1, 2, 3, 4]
    client = GmailImapClient.new(connection)
    assert_equal [1, 2, 3, 4], client.inbox_uids
  end

  test "loads messages from INBOX given their uids" do
    connection = stub('imap-connection', examine: nil)
    connection.stubs(:uid_fetch).with([1, 2], 'BODY.PEEK[]').returns [
      stub(attr: {"BODY[]" => "raw-message-body-1"}),
      stub(attr: {"BODY[]" => "raw-message-body-2"})
    ]
    client = GmailImapClient.new(connection)
    assert_equal ['raw-message-body-1', 'raw-message-body-2'], client.inbox_messages(1, 2)
  end
end