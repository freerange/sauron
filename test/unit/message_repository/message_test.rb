require 'test_helper'

class MessageRepository
  class MessageTest < ActiveSupport::TestCase
    test "returns the body of the raw message" do
      record = stub('record')
      raw_message = Mail.new(body: "message-body").to_s
      assert_equal "message-body", Message.new(record, raw_message).body
    end

    test "prefers the plain text body part" do
      raw_message = Mail.new do
        text_part { body 'plain-text-message-body' }
        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1>'
        end
      end.to_s

      assert_equal 'plain-text-message-body', Message.new(stub('record'), raw_message).body
    end
  end
end