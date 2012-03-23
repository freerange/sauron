require 'test_helper'
require 'account_message_importer'

class AccountMessageImporterTest < ActiveSupport::TestCase
  test 'establishes an imap connection using the given credentials' do
    GmailImapClient.expects(:connect).with('dave@example.com', 'password')
    MessageImporter.stubs(:new).returns(stub_everything)

    AccountMessageImporter.import_for('dave@example.com', 'password')
  end

  test 'uses the established connection for importing' do
    gmail_client = stub('gmail-client')
    GmailImapClient.stubs(:connect).returns(gmail_client)
    MessageImporter.expects(:new).with(gmail_client).returns(stub_everything)

    AccountMessageImporter.import_for('whatever', 'whatever')
  end

  test 'uses the default message repository' do
    GmailImapClient.stubs(:connect).returns(stub('gmail-client'))

    message_repository = stub('message-repository')
    importer = stub('importer')
    MessageRepository.stubs(:instance).returns(message_repository)
    MessageImporter.stubs(:new).returns(importer)
    importer.expects(:import_into).with(message_repository)

    AccountMessageImporter.import_for('whatever', 'whatever')
  end
end
