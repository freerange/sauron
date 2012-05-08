require "test_helper"

class MessageRepository
  class ActiveRecordMailIndexTest < ActiveSupport::TestCase
    test "returns the most recent mails excluding duplicates" do
      most_recent_records = [ActiveRecordMailIndex.new]
      ActiveRecordMailIndex.stubs(:all).with(order: "date DESC", limit: 25, group: :message_id).returns(most_recent_records)
      assert_equal most_recent_records, ActiveRecordMailIndex.most_recent
    end

    test ".mail_exists? returns a truthy value if a mail exists matching the account and uid" do
      given_mail_exists_in_database(account = "a@b.com", uid = 2)
      assert ActiveRecordMailIndex.mail_exists?(account, uid)
    end

    test ".mail_exists? returns a falsey value if no mail exists matching the account and uid" do
      given_mail_does_not_exist_in_database(account = "a@b.com", uid = 2)
      refute ActiveRecordMailIndex.mail_exists?(account, uid)
    end

    test ".highest_uid returns nil if there are no mails" do
      given_no_mails_exist_in_database(account = "a@b.com")
      assert_nil ActiveRecordMailIndex.highest_uid(account)
    end

    test ".highest_uid returns highest UID" do
      given_mail_with_highest_uid_exists_in_database(account = "a@b.com", uid = 999)
      assert_equal uid, ActiveRecordMailIndex.highest_uid(account)
    end

    test ".find_all_by_message_hash(hash) returns all mails with that message hash" do
      mail1 = stub('mail-1')
      mail2 = stub('mail-2')
      given_mails_exist_in_the_database_with_message_hash('abcdef123456', [mail1, mail2])
      assert_equal [mail1, mail2], ActiveRecordMailIndex.find_all_by_message_hash('abcdef123456')
    end

    test ".add(mail, hash) adds message by creating a model" do
      mail = stub('mail', account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today, message_id: "message-id", delivered_to: 'sam@example.com')
      ActiveRecordMailIndex.expects(:create!).with(account: 'sam@example.com', uid: 123, subject: 'Subject', from: 'tom@example.com', date: Date.today, message_id: "message-id", message_hash: "message-hash", delivered_to: 'sam@example.com')
      ActiveRecordMailIndex.add(mail, "message-hash")
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
      ActiveRecordMailIndex.stubs(:where).with(message_hash: hash).returns(scope)
    end
  end
end