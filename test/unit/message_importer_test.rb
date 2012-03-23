require 'test_helper'

class MessageImporterTest < ActiveSupport::TestCase
  test 'imports messages' do
    gmail_client = stub('gmail-client')
    gmail_client.stubs(:inbox_uids).returns([3, 4])
    gmail_client.stubs(:inbox_messages).with(3, 4).returns([:message1, :message2])
    importer = MessageImporter.new(gmail_client)
    repository = stub('repository')
    repository.expects(:store).with(:message1)
    repository.expects(:store).with(:message2)
    importer.import_into(repository)
  end
end
