require 'test_helper'

class MailImporterTest < ActiveSupport::TestCase
  test 'imports mails available in the mailbox' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3, 4])
    mailbox.stubs(:mail).with(3).returns(:mail1)
    mailbox.stubs(:mail).with(4).returns(:mail2)
    importer = MailImporter.new(mailbox)
    repository = stub('repository', highest_uid: 3, exists?: false)
    repository.expects(:add).with(:mail1)
    repository.expects(:add).with(:mail2)
    importer.import_into(repository)
  end

  test 'skip mails with uids lower than those already imported' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).with(2).returns([2])
    mailbox.stubs(:mail).returns(:mail_to_import)
    mailbox.stubs(:mail).with(2).returns(:mail2)
    importer = MailImporter.new(mailbox)
    repository = stub('repository', highest_uid: 2, exists?: false)
    repository.expects(:add).with(:mail2)
    importer.import_into(repository)
  end

  test 'skips mails already available in repository' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([5])
    mailbox.expects(:mail).with(5).never
    importer = MailImporter.new(mailbox)
    repository = stub('repository', highest_uid: 5)
    repository.stubs(:exists?).with('tom@example.com', 5).returns(true)
    repository.expects(:add).never
    importer.import_into(repository)
  end

  test 'raises an exception displaying message UID if importing fails' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3])
    mailbox.stubs(:mail).with(3).returns(:mail1)
    importer = MailImporter.new(mailbox)
    repository = stub('repository', highest_uid: 3, exists?: false)
    repository.stubs(:add).raises(Encoding::UndefinedConversionError)

    exception = assert_raises(RuntimeError) do
      importer.import_into(repository)
    end
    assert_match "Failed to import mail with UID=3", exception.message
  end
end
