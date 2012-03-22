require 'test_helper'

class MessageImporter
  attr_reader :message_client

  def initialize(message_client)
    @message_client = message_client
  end

  def import_into(repository)
    message_client.inbox_messages.each do |message|
      repository.store(message)
    end
  end
end

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
