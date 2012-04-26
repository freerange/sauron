require 'test_helper'
require 'account_mail_importer'

class AccountMailImporterTest < ActiveSupport::TestCase
  test 'establishes an imap connection using the given credentials' do
    GoogleMail::Mailbox.expects(:connect).with('dave@example.com', 'password')
    MailImporter.stubs(:new).returns(stub_everything)

    AccountMailImporter.import_for('dave@example.com', 'password')
  end

  test 'uses the established connection for importing' do
    mailbox = stub('mailbox')
    GoogleMail::Mailbox.stubs(:connect).returns(mailbox)
    MailImporter.expects(:new).with(mailbox).returns(stub_everything)

    AccountMailImporter.import_for('whatever', 'whatever')
  end

  test 'uses the default mail repository' do
    GoogleMail::Mailbox.stubs(:connect).returns(stub('mailbox'))

    mail_repository = stub('mail-repository')
    importer = stub('importer')
    MailImporter.stubs(:new).returns(importer)
    importer.expects(:import_into).with(MessageRepository)

    AccountMailImporter.import_for('whatever', 'whatever')
  end
end
