require 'test_helper'
require 'gmail_imap_client'

class GmailImapClient::ConnectionTest < ActiveSupport::TestCase
  test "should connect to the gmail imap server" do
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, true).returns(stub_everything)
    GmailImapClient::Connection.new('email', 'password')
  end

  test "should login using the supplied email and password" do
    email, password = "email", "password"
    imap = stub("imap")
    imap.expects(:login).with(email, password)
    Net::IMAP.stubs(:new).returns(imap)
    GmailImapClient::Connection.new(email, password)
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

  test "should retrieve all inbox messages from the 'INBOX'" do
    connection = stub("imap-connection")
    connection.expects(:select).with("INBOX")
    connection.stubs(:uid_search).with("ALL").returns(["uid-1", "uid-2"])
    connection.stubs(:uid_fetch).with(["uid-1", "uid-2"], "BODY.PEEK[]").returns([
      stub(attr: {"BODY[]" => "raw-message-body-1"}),
      stub(attr: {"BODY[]" => "raw-message-body-2"})
    ])
    client = GmailImapClient.new(connection)
    client.inbox_messages
  end
end