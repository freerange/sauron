require 'test_helper'
require 'gmail'

class GmailTest < ActiveSupport::TestCase
  test "should return an empty array when there are no messages" do
    imap = stub_everything
    imap.stubs(:uid_search).returns([])
    Net::IMAP.stubs(:new).returns(imap)
    assert_equal [], Gmail.messages("", "")
  end

  test "should connect to the gmail imap server" do
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, ssl=true).returns(stub_everything)
    Gmail.new("", "")
  end

  test "should login using the supplied email and password" do
    email, password = "email", "password"
    imap = stub("imap")
    imap.expects(:login).with(email, password)
    Net::IMAP.stubs(:new).returns(imap)
    Gmail.new(email, password)
  end

  test "should retrieve all raw messages from the 'INBOX'" do
    imap = stub("imap")
    imap.stubs(:login)
    imap.expects(:select).with("INBOX")
    imap.stubs(:uid_search).with("ALL").returns(["uid-1", "uid-2"])
    imap.stubs(:uid_fetch).with("uid-1", "BODY.PEEK[]").returns([stub(attr: {"BODY[]" => "raw-message-body-1"})])
    imap.stubs(:uid_fetch).with("uid-2", "BODY.PEEK[]").returns([stub(attr: {"BODY[]" => "raw-message-body-2"})])
    Net::IMAP.stubs(:new).returns(imap)
    gmail = Gmail.new("", "")
    gmail.retrieve_raw_messages
  end

  test "should return mail objects representing the messages on the server" do
    messages = [Mail.new("FROM: George")]
    Net::IMAP.stubs(:new).returns(stub_everything)
    gmail = Gmail.new("", "")
    gmail.stubs(:retrieve_raw_messages).returns(["FROM: George"])
    assert_equal messages, gmail.messages
  end
end