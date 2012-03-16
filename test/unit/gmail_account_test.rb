require 'test_helper'
require 'gmail_account'

class GmailAccountTest < ActiveSupport::TestCase
  test "should return an empty array when there are no messages" do
    imap_client = stub(:raw_messages => [])
    GmailImapClient.stubs(:new).returns(imap_client)
    assert_equal [], GmailAccount.messages("", "")
  end

  test "should return mail objects representing the messages on the server" do
    messages = [Mail.new("FROM: George")]
    imap_client = stub(:raw_messages => ["FROM: George"])
    GmailImapClient.stubs(:new).returns(imap_client)
    gmail = GmailAccount.new("", "")
    assert_equal messages, gmail.messages
  end
end