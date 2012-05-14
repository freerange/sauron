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

    test "returns the sender defined by the From: header" do
      raw_message = ::Mail.new(from: "bob@example.com").to_s
      assert_equal "bob@example.com", Mail.new(anything, anything, raw_message).from
    end

    test "returns nil when the message doesn't include a From: header" do
      raw_message = ::Mail.new(from: nil).to_s
      assert_nil Mail.new(anything, anything, raw_message).from
    end

    test "returns the subject" do
      raw_message = ::Mail.new(subject: "email-subject").to_s
      assert_equal "email-subject", Mail.new(anything, anything, raw_message).subject
    end

    test "handles pound signs encoded in Windows-1252 in the subject" do
      subject_with_invalid_encoding = "It costs \xA320. Bargain!".force_encoding("ASCII-8BIT")
      raw_message = "Subject: #{subject_with_invalid_encoding}"
      assert_equal "It costs £20. Bargain!", Mail.new(anything, anything, raw_message).subject
    end

    test "handles ellipsis characters encoded in Windows-1252 in the subject" do
      subject_with_invalid_encoding = "Before \x85 After".force_encoding("ASCII-8BIT")
      raw_message = "Subject: #{subject_with_invalid_encoding}"
      assert_equal "Before … After", Mail.new(anything, anything, raw_message).subject
    end

    test "handles en dashes encoded in Windows-1252 in the subject" do
      subject_with_invalid_encoding = "This \x96 that".force_encoding("ASCII-8BIT")
      raw_message = "Subject: #{subject_with_invalid_encoding}"
      assert_equal "This – that", Mail.new(anything, anything, raw_message).subject
    end

    test "it doesn't do any conversion for strings that are already UTF-8" do
      utf_8_subject = "Unicode = \u00A3".encode("UTF-8")
      raw_message = "Subject: #{utf_8_subject}"
      assert_equal "Unicode = £", Mail.new(anything, anything, raw_message).subject
    end

    test "returns nil when the message has an empty Subject header" do
      raw_message = ::Mail.new(subject: nil).to_s
      assert_nil Mail.new(anything, anything, raw_message).subject
    end

    test "returns the date" do
      raw_message = ::Mail.new(date: "2012-01-01 09:00:00").to_s
      assert_equal Time.parse("2012-01-01 09:00:00"), Mail.new(anything, anything, raw_message).date
    end

    test "returns the message_id" do
      raw_message = ::Mail.new(message_id: "message-123").to_s
      assert_equal "message-123", Mail.new(anything, anything, raw_message).message_id
    end

    test "returns the typical single Delivered-To header as an Array of a single String" do
      raw_mail = "Delivered-To: alice@example.com\n\nmessage-body"
      delivered_to = Mail.new(anything, anything, raw_mail).delivered_to
      assert_equal ["alice@example.com"], delivered_to
    end

    test "returns weird multiple Delivered-To headers as an Array of Strings" do
      raw_mail = "Delivered-To: recipient-1\nDelivered-To: recipient-A\n\nmessage-body"
      delivered_to = Mail.new(anything, anything, raw_mail).delivered_to
      assert_equal ["recipient-1", "recipient-A"], delivered_to
    end

    test "returns the message id in the presence of messed up headers" do
      raw_message = %{Date: Sat, 21 Apr 2012 22:20:07 +0000
From: Pivotal Tracker <tracker-noreply@pivotaltracker.com>
To: jase@example.com,
   james.adam@example.com,
   chris.roos@example.com,
   Peter.herlihy@example.com,
   tom.ward@example.com,
   james.mead@example.com,

  jamie.arnold@example.com,
   neil.williams@example.com,
   frances@example.com,
   ben.terrett@example.com
Message-Id: <4f9332975cb42_1df7ab6da78652@prod-app1.c44903.blueboxgrid.com.tmail>
Subject: Joe Bloggs has requested to be a member of an excitin project on Pivotal Tracker}
      assert_equal "<4f9332975cb42_1df7ab6da78652@prod-app1.c44903.blueboxgrid.com.tmail>", Mail.new(anything, anything, raw_message).message_id
    end
  end
end
