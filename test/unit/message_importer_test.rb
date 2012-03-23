require 'test_helper'

class MessageImporterTest < ActiveSupport::TestCase
  test 'imports messages' do
    gmail_client = stub('gmail-client', inbox_messages: [:message1, :message2])
    importer = MessageImporter.new(gmail_client)
    repository = stub('repository')
    repository.expects(:store).with(:message1)
    repository.expects(:store).with(:message2)
    importer.import_into(repository)
  end
end
