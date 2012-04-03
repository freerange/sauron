require "test_helper"

class MessageRepository
  class RecordTest < ActiveSupport::TestCase
    test "returns the 2500 most recent messages" do
      most_recent_records = [Record.new]
      Record.stubs(:all).with(order: "date DESC", limit: 2500).returns(most_recent_records)
      assert_equal most_recent_records, Record.most_recent
    end
  end
end