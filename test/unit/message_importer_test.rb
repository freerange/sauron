require 'test_helper'

class MessageImporterTest < ActiveSupport::TestCase
  test 'imports messages' do
    gmail_client = stub('gmail-client')
    gmail_client.stubs(:inbox_uids).returns([3, 4])
    gmail_client.stubs(:inbox_message).with(3).returns(:message1)
    gmail_client.stubs(:inbox_message).with(4).returns(:message2)
    importer = MessageImporter.new(gmail_client)
    repository = stub('repository')
    repository.expects(:store).with(3, :message1)
    repository.expects(:store).with(4, :message2)
    importer.import_into(repository)
  end
end
