require 'test_helper'

class GmailAccountTest < ActiveSupport::TestCase
  test "should provide a class method to access account messages" do
    gmail_account = stub(:messages => [:message])
    GmailAccount.expects(:new).with("username", "password").returns(gmail_account)
    assert_equal [:message], GmailAccount.messages("username", "password")
  end

  test "should return an empty array when there are no messages" do
    imap_client = stub(:inbox_messages => [])
    gmail_account = GmailAccount.new("", "", imap_client)
    assert_equal [], gmail_account.messages
  end

  test "should instantiate a new imap client with our credentials" do
    GmailImapClient.expects(:connect).with("email", "password").returns(raw_messages: [])
    GmailAccount.new("email", "password")
  end

  test "should return mail objects representing the messages on the server" do
    messages = [Mail.new("FROM: George")]
    imap_client = stub(:inbox_messages => ["FROM: George"])
    gmail_account = GmailAccount.new("", "", imap_client)
    assert_equal messages, gmail_account.messages
  end
end