# encoding: UTF-8
require 'test_helper'

class MessageRepository
  class MessageTest < ActiveSupport::TestCase

    test "returns the body of the raw message using the store" do
      raw_message = Mail.new(body: "message-body").to_s
      index_records, store = given_stored_message(raw_message)
      assert_equal "message-body", Message.new(index_records, store).body
    end

    test "returns the recipient of the mail" do
      raw_message = Mail.new(body: "message-body", to: "email-address").to_s
      index_records, store = given_stored_message(raw_message)
      assert_equal ["email-address"], Message.new(index_records, store).recipients
    end

    test "returns all recipients of all mails" do
      raw_message_1 = Mail.new(body: "message-body", to: "email-address-1").to_s
      raw_message_2 = Mail.new(body: "message-body", to: "email-address-2").to_s
      index_records, store = given_stored_message(raw_message_1, raw_message_2)
      assert_equal ["email-address-1", "email-address-2"], Message.new(index_records, store).recipients
    end

    test "doesn't load the message body from the store if it is not requested" do
      index_record = stub('index-record', account: 'account', uid: 'uid')
      store = stub('store')
      store.expects(:find).never
      Message.new([index_record], store)
    end

    test "body should be in UTF-8 even if raw message is in non UTF-8 encoding" do
      raw_message = Mail.new(
        charset: 'ISO-8859-1',
        body: 'Telefónica'.encode('ISO-8859-1', 'UTF-8')
      ).encoded

      index_record, store = given_stored_message(raw_message)
      assert_equal 'Telefónica', Message.new(index_record, store).body
    end

    test "body should not fail decoding if charset unknown" do
      raw_message = Mail.new(
        charset: 'unknown',
        body: 'Anything'
      ).encoded

      index_record, store = given_stored_message(raw_message)
      assert_nothing_raised { Message.new(index_record, store).body }
    end

    test "body should be in UTF-8 even if raw message contains text part which is in non UTF-8 encoding" do
      raw_message = Mail.new do
        text_part do
          content_type 'text/plain; charset=ISO-8859-1'
          body 'Telefónica'.encode('ISO-8859-1', 'UTF-8')
        end
      end.encoded

      index_record, store = given_stored_message(raw_message)
      assert_equal 'Telefónica', Message.new(index_record, store).body
    end

    test "prefers the plain text body part" do
      raw_message = Mail.new do
        text_part { body 'plain-text-message-body' }
        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1>'
        end
      end.encoded

      index_records, store = given_stored_message(raw_message)
      assert_equal 'plain-text-message-body', Message.new(index_records, store).body
    end

    test "shows all text parts when they are separated by an attachment" do
      raw_message = Mail.new do
        text_part { body 'before-attachment' }
        add_file(__FILE__)
        text_part { body 'after-attachment' }
      end.encoded

      index_records, store = given_stored_message(raw_message)
      assert_match /before-attachment/, Message.new(index_records, store).body
      assert_match /after-attachment/, Message.new(index_records, store).body
    end

    test "shows text parts that are nested within multipart/alternative parts" do
      raw_message = Mail.new do
        part do |p|
          p.text_part { body 'within-part' }
        end
      end.encoded

      index_records, store = given_stored_message(raw_message)
      assert_match /within-part/, Message.new(index_records, store).body
    end

    private

    def given_stored_message(*raw_messages)
      store = stub('store')
      index_records = raw_messages.map.with_index do |raw_message, index|
        store.stubs(:find).with('account', index).returns(raw_message)
        stub('index-record', account: 'account', uid: index)
      end
      [index_records, store]
    end
  end
end