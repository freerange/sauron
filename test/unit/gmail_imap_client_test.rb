require 'test_helper'
require 'gmail_imap_client'

class GmailImapClientTest < ActiveSupport::TestCase
  test "should connect to the gmail imap server" do
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, ssl=true).returns(stub_everything)
    GmailImapClient.connect('email', 'password')
  end

  test "should login using the supplied email and password" do
    email, password = "email", "password"
    imap = stub("imap")
    imap.expects(:login).with(email, password)
    Net::IMAP.stubs(:new).returns(imap)
    GmailImapClient.connect(email, password)
  end

  test "should return a new client with the authenticated connection" do
    client = stub('client')
    imap = stub_everything('imap')
    Net::IMAP.stubs(:new).returns(imap)
    GmailImapClient.stubs(:new).with(imap).returns(client)
    assert_equal client, GmailImapClient.connect('email', 'password')
  end

  test "should retrieve all raw messages from the 'INBOX'" do
    imap = stub("imap")
    imap.stubs(:login)
    imap.expects(:select).with("INBOX")
    imap.stubs(:uid_search).with("ALL").returns(["uid-1", "uid-2"])
    imap.stubs(:uid_fetch).with("uid-1", "BODY.PEEK[]").returns([stub(attr: {"BODY[]" => "raw-message-body-1"})])
    imap.stubs(:uid_fetch).with("uid-2", "BODY.PEEK[]").returns([stub(attr: {"BODY[]" => "raw-message-body-2"})])
    Net::IMAP.stubs(:new).returns(imap)
    client = GmailImapClient.connect('', '')
    client.raw_messages
  end
end