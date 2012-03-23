require 'test_helper'
require 'account_message_importer'

class AccountMessageImporterTest < ActiveSupport::TestCase
  test 'establishes an imap connection using the given credentials' do
    GoogleMail::Mailbox.expects(:connect).with('dave@example.com', 'password')
    MessageImporter.stubs(:new).returns(stub_everything)

    AccountMessageImporter.import_for('dave@example.com', 'password')
  end

  test 'uses the established connection for importing' do
    mailbox = stub('mailbox')
    GoogleMail::Mailbox.stubs(:connect).returns(mailbox)
    MessageImporter.expects(:new).with(mailbox).returns(stub_everything)

    AccountMessageImporter.import_for('whatever', 'whatever')
  end

  test 'uses the default message repository' do
    GoogleMail::Mailbox.stubs(:connect).returns(stub('mailbox'))

    message_repository = stub('message-repository')
    importer = stub('importer')
    MessageRepository.stubs(:instance).returns(message_repository)
    MessageImporter.stubs(:new).returns(importer)
    importer.expects(:import_into).with(message_repository)

    AccountMessageImporter.import_for('whatever', 'whatever')
  end
end
