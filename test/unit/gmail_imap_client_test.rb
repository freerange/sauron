require 'test_helper'
require 'gmail_imap_client'

class GmailImapClientTest < ActiveSupport::TestCase
  test "should connect to the gmail imap server" do
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, ssl=true).returns(stub_everything)
    GmailImapClient.new("", "")
  end

  test "should login using the supplied email and password" do
    email, password = "email", "password"
    imap = stub("imap")
    imap.expects(:login).with(email, password)
    Net::IMAP.stubs(:new).returns(imap)
    GmailImapClient.new(email, password)
  end

  test "should retrieve all raw messages from the 'INBOX'" do
    imap = stub("imap")
    imap.stubs(:login)
    imap.expects(:select).with("INBOX")
    imap.stubs(:uid_search).with("ALL").returns(["uid-1", "uid-2"])
    imap.stubs(:uid_fetch).with("uid-1", "BODY.PEEK[]").returns([stub(attr: {"BODY[]" => "raw-message-body-1"})])
    imap.stubs(:uid_fetch).with("uid-2", "BODY.PEEK[]").returns([stub(attr: {"BODY[]" => "raw-message-body-2"})])
    Net::IMAP.stubs(:new).returns(imap)
    client = GmailImapClient.new("", "")
    client.raw_messages
  end
end