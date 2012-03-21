require 'test_helper'

class GmailAccountTest < ActiveSupport::TestCase
  test "should instantiate a new imap client with our credentials" do
    GmailAccount.email = 'email'
    GmailAccount.password = 'password'
    GmailImapClient.expects(:connect).with("email", "password").returns(stub('client'))
    GmailAccount.stubs(:new).returns(stub('account', messages: []))
    GmailAccount.messages
  end

  test "should use imap client to build new instance" do
    client = stub('client')
    GmailImapClient.stubs(:connect).returns(client)
    GmailAccount.expects(:new).with(client).returns(stub('account', messages: []))
    GmailAccount.messages
  end

  test "should return messages from newly built instance" do
    GmailImapClient.stubs(:connect)
    account = stub('account')
    account.stubs(:messages).returns([:message1, :message2])
    GmailAccount.stubs(:new).returns(account)
    assert_equal [:message1, :message2], GmailAccount.messages
  end

  test "should return an empty array when there are no messages" do
    imap_client = stub(:inbox_messages => [])
    gmail_account = GmailAccount.new(imap_client)
    assert_equal [], gmail_account.messages
  end

  test "should return mail objects representing the messages on the server" do
    messages = [Mail.new("FROM: George")]
    imap_client = stub(:inbox_messages => ["FROM: George"])
    gmail_account = GmailAccount.new(imap_client)
    assert_equal messages, gmail_account.messages
  end
end