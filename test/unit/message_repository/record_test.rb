require "test_helper"

class MessageRepository
  class RecordTest < ActiveSupport::TestCase
    test "returns the 2500 most recent messages" do
      most_recent_records = [Record.new]
      Record.stubs(:all).with(order: "date DESC", limit: 2500).returns(most_recent_records)
      assert_equal most_recent_records, Record.most_recent
    end

    test ".message_exists? returns a truthy value if a message exists matching the account and uid" do
      given_message_exists_in_database(account = "a@b.com", uid = 2)
      assert Record.message_exists?(account, uid)
    end

    test ".message_exists? returns a falsey value if no message exists matching the account and uid" do
      given_message_does_not_exist_in_database(account = "a@b.com", uid = 2)
      refute Record.message_exists?(account, uid)
    end

    private

    def given_message_exists_in_database(account, uid)
      Record.stubs(:exists?).with(account: account, uid: uid).returns(true)
    end

    def given_message_does_not_exist_in_database(account, uid)
      Record.stubs(:exists?).with(account: account, uid: uid).returns(false)
    end
  end
end