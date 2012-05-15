# encoding: utf-8
require 'test_helper'
require 'ostruct'

class GoogleMail::Mailbox
  class MailTest < ActiveSupport::TestCase
    test "returns the account" do
      assert_equal "789", Mail.new("789", anything, anything).account
    end

    test "returns the uid" do
      assert_equal "1234", Mail.new(anything, "1234", anything).uid
    end

    test "returns the raw message" do
      assert_equal "raw-message", Mail.new(anything, anything, "raw-message").raw
    end

    test "is equal to another mail if account, uid & raw message are the same" do
      mail_1 = Mail.new("account", "uid", "raw-message")
      mail_2 = Mail.new("account", "uid", "raw-message")
      assert_equal mail_1, mail_2
    end

    test "is not equal to another mail if account is different" do
      mail_1 = Mail.new("account-1", "uid", "raw-message")
      mail_2 = Mail.new("account-2", "uid", "raw-message")
      refute_equal mail_1, mail_2
    end

    test "is not equal to another mail if uid is different" do
      mail_1 = Mail.new("account", "uid-1", "raw-message")
      mail_2 = Mail.new("account", "uid-2", "raw-message")
      refute_equal mail_1, mail_2
    end

    test "is not equal to another mail if raw message is different" do
      mail_1 = Mail.new("account", "uid", "raw-message-1")
      mail_2 = Mail.new("account", "uid", "raw-message-2")
      refute_equal mail_1, mail_2
    end

    test "is not equal to another object if its not a mail" do
      mail = Mail.new("account", "uid", "raw-message")
      object = OpenStruct.new(account: "account", uid: "uid", raw: "raw-message")
      refute_equal mail, object
    end

    test "creates a ParsedMail instance to handle mail parsing" do
      assert_equal ParsedMail.new('raw-message'), Mail.new(anything, anything, "raw-message").parsed_mail
    end

    [:date, :message_id, :from, :subject, :body, :delivered_to].each do |delegated_method|
      test "delegates #{delegated_method} to the ParsedMail instance" do
        mail = Mail.new(anything, anything, "raw-message")
        result = stub('delegated-result')
        mail.parsed_mail.stubs(delegated_method).returns(result)
        assert_equal result, mail.__send__(delegated_method)
      end
    end
  end
end
