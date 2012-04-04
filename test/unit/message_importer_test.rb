require 'test_helper'

class MessageImporterTest < ActiveSupport::TestCase
  test 'imports messages available in the mailbox' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3, 4])
    mailbox.stubs(:message).with(3).returns(:message1)
    mailbox.stubs(:message).with(4).returns(:message2)
    importer = MessageImporter.new(mailbox)
    repository = stub('repository', exists?: false)
    repository.expects(:add).with('tom@example.com', 3, :message1)
    repository.expects(:add).with('tom@example.com', 4, :message2)
    importer.import_into(repository)
  end

  test 'skips messages already available in repository' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([5])
    mailbox.expects(:message).with(5).never
    importer = MessageImporter.new(mailbox)
    repository = stub('repository')
    repository.stubs(:exists?).with('tom@example.com', 5).returns(true)
    repository.expects(:add).never
    importer.import_into(repository)
  end

  test 'raises an exception if importing fails' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3])
    mailbox.stubs(:message).with(3).returns(:message1)
    importer = MessageImporter.new(mailbox)
    repository = stub('repository', exists?: false)
    repository.stubs(:add).raises(Encoding::UndefinedConversionError)

    assert_raises(MessageImporter::ImportError) do
      importer.import_into(repository)
    end
  end

  test 'stores the UID of the failing message in the exception' do
    mailbox = stub('mailbox', email: 'tom@example.com')
    mailbox.stubs(:uids).returns([3])
    mailbox.stubs(:message).with(3).returns(:message1)
    importer = MessageImporter.new(mailbox)
    repository = stub('repository', exists?: false)
    repository.stubs(:add).raises(Encoding::UndefinedConversionError)

    exception = nil
    begin
      importer.import_into(repository)
    rescue MessageImporter::ImportError => e
      exception = e
    end

    assert_equal 3, exception.uid
  end
end

class MessageImporterTest::ImportErrorTest < ActiveSupport::TestCase
  test 'displays the UID as part of its string representation' do
    assert_match /Failed to import message with UID=3/, MessageImporter::ImportError.new(3).message
  end
end