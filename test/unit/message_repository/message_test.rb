# encoding: UTF-8
require 'test_helper'

class MessageRepository
  class MessageTest < ActiveSupport::TestCase
    test "returns the body of the raw message" do
      raw_message = Mail.new(body: "message-body").encoded
      message = Message.new(stub('record'), raw_message)
      assert_equal "message-body", message.body
    end

    test "body should be in UTF-8 even if raw message is in non UTF-8 encoding" do
      raw_message = Mail.new(
        charset: 'ISO-8859-1',
        body: 'Telefónica'.encode('ISO-8859-1', 'UTF-8')
      ).encoded
      assert_equal 'Telefónica', Message.new(stub('record'), raw_message).body
    end

    test "body should not fail decoding if charset unknown" do
      raw_message = Mail.new(
        charset: 'unknown',
        body: 'Anything'
      ).encoded
      assert_nothing_raised { Message.new(stub('record'), raw_message).body }
    end

    test "body should be in UTF-8 even if raw message contains text part which is in non UTF-8 encoding" do
      raw_message = Mail.new do
        text_part do
          content_type 'text/plain; charset=ISO-8859-1'
          body 'Telefónica'.encode('ISO-8859-1', 'UTF-8')
        end
      end.encoded
      assert_equal 'Telefónica', Message.new(stub('record'), raw_message).body
    end

    test "prefers the plain text body part" do
      raw_message = Mail.new do
        text_part { body 'plain-text-message-body' }
        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1>'
        end
      end.encoded
      message = Message.new(stub('record'), raw_message)
      assert_equal 'plain-text-message-body', message.body
    end

    test "shows all text parts when they are separated by an attachment" do
      raw_message = Mail.new do
        text_part { body 'before-attachment' }
        add_file(__FILE__)
        text_part { body 'after-attachment' }
      end.encoded
      message = Message.new(stub('record'), raw_message)
      assert_match /before-attachment/, message.body
      assert_match /after-attachment/, message.body
    end

    test "shows text parts that are nested within multipart/alternative parts" do
      raw_message = Mail.new do
        part do |p|
          p.text_part { body 'within-part' }
        end
      end.encoded
      message = Message.new(stub('record'), raw_message)
      assert_match /within-part/, message.body
    end
  end
end