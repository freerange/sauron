# encoding: UTF-8
require 'test_helper'

class MessageRepository
  class MessageTest < ActiveSupport::TestCase

    test "returns the body of the raw message using the store" do
      raw_mail = Mail.new(body: "message-body").to_s
      index_record, store = given_stored_message(raw_mail)
      assert_equal "message-body", Message.new(index_record, store).body
    end

    test "returns the recipient of the mail as who it was delivered to" do
      raw_mail = Mail.new(body: "message-body", delivered_to: "email-address").to_s
      index_record, store = given_stored_message(raw_mail)
      assert_equal ["email-address"], Message.new(index_record, store).recipients
    end

    test "returns all recipients of all mails in a message" do
      raw_mail_1 = Mail.new(body: "message-body", delivered_to: "recipient-1").to_s
      raw_mail_2 = Mail.new(body: "message-body", delivered_to: "recipient-2").to_s
      raw_sent_message = Mail.new(body: "message-body").to_s
      index_record, store = given_stored_message(raw_mail_1, raw_mail_2, raw_sent_message)
      assert_equal ["recipient-1", "recipient-2"], Message.new(index_record, store).recipients
    end

    test "indicates that the message was delivered to the specified email address" do
      raw_mail = Mail.new(body: "message-body", delivered_to: "email-address").to_s
      index_record, store = given_stored_message(raw_mail)
      assert Message.new(index_record, store).received_by?("email-address")
    end

    test "indicates that the message was not delivered to the specified email address" do
      raw_mail = Mail.new(body: "message-body", delivered_to: "other-email-address").to_s
      index_record, store = given_stored_message(raw_mail)
      refute Message.new(index_record, store).received_by?("email-address")
    end

    test "indicates that the message was sent by the specified email address" do
      raw_mail = Mail.new(body: "message-body", from: "email-address").to_s
      index_record, store = given_stored_message(raw_mail)
      assert Message.new(index_record, store).sent_by?("email-address")
    end

    test "indicates that the message was not sent by the specified email address" do
      raw_mail = Mail.new(body: "message-body", from: "other-email-address").to_s
      index_record, store = given_stored_message(raw_mail)
      refute Message.new(index_record, store).sent_by?("email-address")
    end

    test "doesn't load the message body from the store if it is not requested" do
      index_record = stub('index-record', account: 'account', uid: 'uid')
      store = stub('store')
      store.expects(:find).never
      Message.new([index_record], store)
    end

    test "delegates body to the ParsedMail instance" do
      message = Message.new(anything, "raw-message")
      parsed_mail = stub('parsed_mail')
      result = stub('delegated-result')
      parsed_mail.stubs(:body).returns(result)
      message.stubs(:parsed_mail).returns(parsed_mail)
      assert_equal result, message.body
    end

    private

    def given_stored_message(*raw_mails)
      store = stub('store')
      from = nil
      recipients = []
      raw_mails.map.with_index do |raw_mail, index|
        store.stubs(:find).with('account', index).returns(raw_mail)
        mail = Mail.new(raw_mail)
        from = mail.from ? mail.from.first : nil
        recipients += [mail['Delivered-To']].flatten.map { |x| x.to_s.to_s }
      end
      primary_message_index_record = stub('index-record', from: from, recipients: recipients, mail_identifier: ['account', 0])
      [primary_message_index_record, store]
    end
  end
end
