require "test_helper"

class MessageRepository
  class RecordTest < ActiveSupport::TestCase
    test "returns the 2500 most recent messages" do
      Record.expects(:all).with(order: "date DESC", limit: 2500)
      Record.most_recent
    end
  end
end