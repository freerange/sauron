require 'test_helper'

class MailImporterTest < ActiveSupport::TestCase
  test 'imports mails available in the mailbox' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3, 4])
    mailbox.stubs(:mail).with(3).returns(:mail1)
    mailbox.stubs(:mail).with(4).returns(:mail2)
    importer = MailImporter.new(mailbox)
    message_repository = stub('message-repository', highest_mail_uid: 3, mail_exists?: false)
    message_repository.expects(:add_mail).with(:mail1).returns(:message1)
    message_repository.expects(:add_mail).with(:mail2).returns(:message2)
    conversation_repository = stub('conversation-repository')
    conversation_repository.expects(:add_message).with(:message1)
    conversation_repository.expects(:add_message).with(:message2)
    importer.import_into(message_repository, conversation_repository)
  end

  test 'skip mails with uids lower than those already imported' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.expects(:uids).with(2).returns([2])
    mailbox.stubs(:mail).with(2).returns(:mail2)
    importer = MailImporter.new(mailbox)
    message_repository = stub('message-repository', highest_mail_uid: 2, mail_exists?: false)
    message_repository.stubs(:add_mail)
    conversation_repository = stub_everything('conversation-repository')
    importer.import_into(message_repository, conversation_repository)
  end

  test 'skips mails already available in message repository' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([5])
    mailbox.expects(:mail).with(5).never
    importer = MailImporter.new(mailbox)
    message_repository = stub('message-repository', highest_mail_uid: 5)
    message_repository.stubs(:mail_exists?).with('tom@example.com', 5).returns(true)
    message_repository.expects(:add_mail).never
    conversation_repository = stub_everything('conversation-repository')
    conversation_repository.expects(:add_message).never
    importer.import_into(message_repository, conversation_repository)
  end

  test 'raises an exception displaying message UID if importing fails' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3])
    mailbox.stubs(:mail).with(3).returns(:mail1)
    importer = MailImporter.new(mailbox)
    message_repository = stub('message-repository', highest_mail_uid: 3, mail_exists?: false)
    message_repository.stubs(:add_mail).raises(Encoding::UndefinedConversionError)
    conversation_repository = stub_everything('conversation-repository')

    exception = assert_raises(RuntimeError) do
      importer.import_into(message_repository, conversation_repository)
    end
    assert_match "Failed to import mail with UID=3", exception.message
  end
end
