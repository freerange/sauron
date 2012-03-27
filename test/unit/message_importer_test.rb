require 'test_helper'

class MessageImporterTest < ActiveSupport::TestCase
  stub(:mailbox, email: 'tom@example.com')

  test 'imports messages available in the mailbox' do
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
    mailbox.stubs(:uids).returns([5])
    mailbox.expects(:message).with(5).never
    importer = MessageImporter.new(mailbox)
    repository = stub('repository')
    repository.stubs(:exists?).with('tom@example.com', 5).returns(true)
    repository.expects(:add).never
    importer.import_into(repository)
  end
end
