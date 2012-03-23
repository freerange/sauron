require 'test_helper'

class MessageImporterTest < ActiveSupport::TestCase
  test 'imports messages available in the client' do
    gmail_client = stub('gmail-client')
    gmail_client.stubs(:inbox_uids).returns([3, 4])
    gmail_client.stubs(:inbox_message).with(3).returns(:message1)
    gmail_client.stubs(:inbox_message).with(4).returns(:message2)
    importer = MessageImporter.new(gmail_client)
    repository = stub('repository', include?: false)
    repository.expects(:store).with(3, :message1)
    repository.expects(:store).with(4, :message2)
    importer.import_into(repository)
  end

  test 'skips messages already available in repository' do
    gmail_client = stub('gmail-client')
    gmail_client.stubs(:inbox_uids).returns([5])
    gmail_client.expects(:inbox_message).with(5).never
    importer = MessageImporter.new(gmail_client)
    repository = stub('repository')
    repository.stubs(:include?).with(5).returns(true)
    repository.expects(:store).never
    importer.import_into(repository)
  end
end
