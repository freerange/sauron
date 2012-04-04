require 'test_helper'

class MessageRepository
  class MessageTest < ActiveSupport::TestCase
    test "returns the body of the raw message" do
      record = stub('record')
      raw_message = Mail.new(body: "message-body").to_s
      assert_equal "message-body", Message.new(record, raw_message).body
    end
  end
end