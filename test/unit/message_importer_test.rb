require 'test_helper'

class MessageImporter::WhenCoordinating < ActiveSupport::TestCase
  test 'establishes an imap connection using the given credentials' do
    GmailImapClient.expects(:connect).with('dave@example.com', 'password')
    MessageImporter.stubs(:new).returns(stub_everything)

    MessageImporter.import_for('dave@example.com', 'password')
  end

  test 'uses the established connection for importing' do
    gmail_client = stub('gmail-client')
    GmailImapClient.stubs(:connect).returns(gmail_client)

    MessageImporter.expects(:new).with(gmail_client).returns(stub_everything)
    MessageImporter.import_for('whatever', 'whatever')
  end

  test 'uses the default message repository' do
    GmailImapClient.stubs(:connect).returns(stub('gmail-client'))

    message_repository = stub('message-repository')
    importer = stub('importer')
    MessageRepository.stubs(:instance).returns(message_repository)
    MessageImporter.stubs(:new).returns(importer)
    importer.expects(:import_into).with(message_repository)

    MessageImporter.import_for('whatever', 'whatever')
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
