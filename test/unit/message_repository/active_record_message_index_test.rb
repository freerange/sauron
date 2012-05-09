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
  end

  class ActiveRecordMessageIndexTest < ActiveSupport::TestCase
    test "returns the most recent mails excluding duplicates" do
      most_recent_records = [ActiveRecordMessageIndex.new]
      ActiveRecordMessageIndex.stubs(:all).with(order: "date DESC", limit: 500, group: :message_id).returns(most_recent_records)
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

    test ".find_all_by_message_hash(hash) finds all message_index records for the message that this mail represents, with lowest id first" do
      all = [stub('message-index-record-1'), stub('message-index-record-2')]
      message_index_records = stub('message_index_records', all: all)
      scope = stub('scope') { stubs(:order).with("id ASC").returns(message_index_records) }
      ActiveRecordMessageIndex.stubs(:where).with(message_hash: 'message-hash').returns(scope)
      assert_equal all, ActiveRecordMessageIndex.find_all_by_message_hash('message-hash')
    end

    test ".add(mail, hash) creates a new message_index record and mail_index record and adds the new mail_index record to the primary message_index record" do
      mail = stub('mail', account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today, message_id: "message-id", delivered_to: 'sam@example.com')
      primary_message_index_record = stub('primary-message-index', id: 456)
      new_message_index_record = stub('message-index', id: 789)
      ActiveRecordMessageIndex.expects(:create!).with(account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today, message_id: "message-id", message_hash: "message-hash", delivered_to: 'sam@example.com').returns(new_message_index_record)
      ActiveRecordMessageIndex.stubs(:find_primary_message_index_record).with('message-hash').returns(primary_message_index_record)
      ActiveRecordMailIndex.expects(:create!).with(message_index_id: 456, account: 'sam@example.com', uid: 123, delivered_to: 'sam@example.com')
      ActiveRecordMessageIndex.add(mail, "message-hash")
    end

    test ".find_primary_message_index_record(hash) finds the message_index record with the lowest id, for the message that this mail represents" do
      message_index_record = stub('message-index-record')
      scope = stub('scope') { stubs(:order).with("id ASC").returns([message_index_record]) }
      ActiveRecordMessageIndex.stubs(:where).with(message_hash: 'message-hash').returns(scope)
      assert_equal message_index_record, ActiveRecordMessageIndex.find_primary_message_index_record('message-hash')
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
      ActiveRecordMessageIndex.stubs(:exists?).with(account: account, uid: uid).returns(true)
    end

    def given_mail_does_not_exist_in_database(account, uid)
      ActiveRecordMessageIndex.stubs(:exists?).with(account: account, uid: uid).returns(false)
    end

    def given_mail_with_highest_uid_exists_in_database(account, uid)
      scope = stub("scope") { stubs(:maximum).with(:uid).returns(uid) }
      ActiveRecordMessageIndex.stubs(:where).with(account: account).returns(scope)
    end

    def given_no_mails_exist_in_database(account)
      scope = stub("scope") { stubs(:maximum).with(:uid).returns(nil) }
      ActiveRecordMessageIndex.stubs(:where).with(account: account).returns(scope)
    end

    def given_mails_exist_in_the_database_with_message_hash(hash, mails)
      scope = stub("scope") { stubs(:all).returns(mails) }
      ActiveRecordMessageIndex.stubs(:where).with(message_hash: hash).returns(scope)
    end
  end
end