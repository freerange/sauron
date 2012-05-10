require "test_helper"

class MessageRepository
  class ActiveRecordMessageIndexDatabaseTest < ActiveSupport::TestCase
    test "has many mail index records" do
      message_index_record = ActiveRecordMessageIndex.create!
      mail_index_record_1 = ActiveRecordMailIndex.create!(message_index_id: message_index_record.id)
      mail_index_record_2 = ActiveRecordMailIndex.create!(message_index_id: message_index_record.id)
      mail_index_records = message_index_record.mail_index_records
      assert mail_index_records.include?(mail_index_record_1)
      assert mail_index_records.include?(mail_index_record_2)
    end

    test "recipients includes the delivered_to addresses for all its constituent mails" do
      mail_1 = GoogleMail::Mailbox::Mail.new('account-1', 1, Mail.new(delivered_to: 'delivered-to-1').to_s)
      mail_2 = GoogleMail::Mailbox::Mail.new('account-2', 2, Mail.new(delivered_to: 'delivered-to-2').to_s)
      ActiveRecordMessageIndex.add(mail_1, 'message-hash')
      ActiveRecordMessageIndex.add(mail_2, 'message-hash')
      record = ActiveRecordMessageIndex.find_by_message_hash('message-hash')
      assert record.recipients.include?('delivered-to-1')
      assert record.recipients.include?('delivered-to-2')
    end

    test "identifies first mail for this message" do
      mail_1 = GoogleMail::Mailbox::Mail.new('account-1', 1, Mail.new(delivered_to: 'delivered-to-1').to_s)
      mail_2 = GoogleMail::Mailbox::Mail.new('account-2', 2, Mail.new(delivered_to: 'delivered-to-2').to_s)
      ActiveRecordMessageIndex.add(mail_1, 'message-hash')
      ActiveRecordMessageIndex.add(mail_2, 'message-hash')
      record = ActiveRecordMessageIndex.find_by_message_hash('message-hash')
      assert_equal ['account-1', 1], record.mail_identifier
    end
  end

  class ActiveRecordMessageIndexTest < ActiveSupport::TestCase
    test "returns the most recent mails" do
      most_recent_records = [ActiveRecordMessageIndex.new]
      ActiveRecordMessageIndex.stubs(:all).with(order: "date DESC", limit: 500).returns(most_recent_records)
      assert_equal most_recent_records, ActiveRecordMessageIndex.most_recent
    end

    test ".mail_exists? returns a truthy value if a mail exists matching the account and uid" do
      given_mail_exists_in_database(account = "a@b.com", uid = 2)
      assert ActiveRecordMessageIndex.mail_exists?(account, uid)
    end

    test ".mail_exists? returns a falsey value if no mail exists matching the account and uid" do
      given_mail_does_not_exist_in_database(account = "a@b.com", uid = 2)
      refute ActiveRecordMessageIndex.mail_exists?(account, uid)
    end

    test ".highest_uid returns nil if there are no mails" do
      given_no_mails_exist_in_database(account = "a@b.com")
      assert_nil ActiveRecordMessageIndex.highest_uid(account)
    end

    test ".highest_uid returns highest UID" do
      given_mail_with_highest_uid_exists_in_database(account = "a@b.com", uid = 999)
      assert_equal uid, ActiveRecordMessageIndex.highest_uid(account)
    end

    test ".find_by_message_hash(hash) finds the message_index record with the specified message hash" do
      message_index_record = stub('message-index-record')
      scope = stub('scope', includes: [message_index_record])
      ActiveRecordMessageIndex.stubs(:where).with(message_hash: 'message-hash').returns(scope)
      assert_equal message_index_record, ActiveRecordMessageIndex.find_by_message_hash('message-hash')
    end

    test "#recipients returns delivered_to addresses for all its mail index records" do
      message_index_record = ActiveRecordMessageIndex.new
      mail_index_record_1 = stub('mail-index-1', delivered_to: 'alice@example.com')
      mail_index_record_2 = stub('mail-index-2', delivered_to: 'bob@example.com')
      message_index_record.stubs(:mail_index_records).returns([mail_index_record_1, mail_index_record_2])
      assert message_index_record.recipients.include?('alice@example.com')
      assert message_index_record.recipients.include?('bob@example.com')
    end

    private

    def given_mail_exists_in_database(account, uid)
      ActiveRecordMailIndex.stubs(:exists?).with(account: account, uid: uid).returns(true)
    end

    def given_mail_does_not_exist_in_database(account, uid)
      ActiveRecordMailIndex.stubs(:exists?).with(account: account, uid: uid).returns(false)
    end

    def given_mail_with_highest_uid_exists_in_database(account, uid)
      scope = stub("scope") { stubs(:maximum).with(:uid).returns(uid) }
      ActiveRecordMailIndex.stubs(:where).with(account: account).returns(scope)
    end

    def given_no_mails_exist_in_database(account)
      scope = stub("scope") { stubs(:maximum).with(:uid).returns(nil) }
      ActiveRecordMailIndex.stubs(:where).with(account: account).returns(scope)
    end

    def given_mails_exist_in_the_database_with_message_hash(hash, mails)
      scope = stub("scope") { stubs(:all).returns(mails) }
      ActiveRecordMessageIndex.stubs(:where).with(message_hash: hash).returns(scope)
    end
  end
end