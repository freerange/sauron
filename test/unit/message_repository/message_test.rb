require 'test_helper'

class MessageRepository
  class MessageTest < ActiveSupport::TestCase
    test "returns the body of the raw message" do
      raw_message = Mail.new(body: "message-body").to_s
      message = Message.new(stub('record'), raw_message)
      assert_equal "message-body", message.body
    end

    test "prefers the plain text body part" do
      raw_message = Mail.new do
        text_part { body 'plain-text-message-body' }
        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1>'
        end
      end.to_s
      message = Message.new(stub('record'), raw_message)
      assert_equal 'plain-text-message-body', message.body
    end

    test "shows all text parts when they are separated by an attachment" do
      raw_message = Mail.new do
        text_part { body 'before-attachment' }
        add_file(__FILE__)
        text_part { body 'after-attachment' }
      end.to_s
      message = Message.new(stub('record'), raw_message)
      assert_match /before-attachment/, message.body
      assert_match /after-attachment/, message.body
    end

    test "shows text parts that are nested within multipart/alternative parts" do
      raw_message = Mail.new do
        part do |p|
          p.text_part { body 'within-part' }
        end
      end.to_s
      message = Message.new(stub('record'), raw_message)
      assert_match /within-part/, message.body
    end
  end
end