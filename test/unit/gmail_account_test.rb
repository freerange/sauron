require 'test_helper'
require 'gmail_account'

class GmailAccountTest < ActiveSupport::TestCase
  test "should provide a class method to access account messages" do
    gmail_account = stub(:messages => [:message])
    GmailAccount.expects(:new).with("username", "password").returns(gmail_account)
    assert_equal [:message], GmailAccount.messages("username", "password")
  end

  test "should return an empty array when there are no messages" do
    imap_client = stub(:connect_as => nil, :raw_messages => [])
    gmail_account = GmailAccount.new("", "", imap_client)
    assert_equal [], gmail_account.messages
  end

  test "should tell the imap client to connect using our credentials" do
    imap_client = stub('imap client')
    imap_client.expects(:connect_as).with("email", "password")
    GmailAccount.new("email", "password", imap_client)
  end

  test "should instantiate an imap client" do
    GmailImapClient.expects(:new).returns(stub(:connect_as => nil, :raw_messages => []))
    GmailAccount.new("", "")
  end

  test "should return mail objects representing the messages on the server" do
    messages = [Mail.new("FROM: George")]
    imap_client = stub(:connect_as => nil, :raw_messages => ["FROM: George"])
    gmail_account = GmailAccount.new("", "", imap_client)
    assert_equal messages, gmail_account.messages
  end
end